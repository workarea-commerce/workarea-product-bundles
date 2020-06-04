module Workarea
  class UpdateKitVariant
    attr_reader :variant, :params
    def initialize(variant, params)
      @variant = variant
      @params = params
    end

    def perform
      Sidekiq::Callbacks.disable(UpdateKitInventory) do
        update_model
        update_pricing
        update_inventory
        update_fulfillment

        @variant.save!
      end
    end

    def original_sku
      params[:original_sku]
    end

    def sku_changed?
      params[:original_sku] != params[:variant][:sku]
    end

    def update_model
      @variant.assign_attributes(params[:variant])

      @variant.details = HashUpdate.new(
        original: @variant.details,
        adds: params[:new_details],
        updates: params[:details],
        removes: params[:details_to_remove]
      ).result

      UpdateVariantComponents.new(
        @variant,
        params[:components]
      ).perform
    end

    def update_pricing
      return unless params[:pricing].present?

      pricing_sku = Pricing::Sku.find_or_initialize_by(id: original_sku)

      if sku_changed?
        new_pricing_sku = Pricing::Sku.find(variant.sku) rescue nil
        new_pricing_sku ||= pricing_sku.dup.tap { |sku| sku.id = variant.sku }

        pricing_sku.destroy!
        pricing_sku = new_pricing_sku
      end

      price = pricing_sku.prices.first || pricing_sku.prices.build
      price.regular = params[:pricing][:regular]
      pricing_sku.update(tax_code: params[:pricing][:tax_code])
    end

    def update_inventory
      inventory = Inventory::Sku.find_or_initialize_by(id: original_sku)

      if sku_changed?
        Inventory::Sku.create!(
          inventory.as_document.merge(
            'id' => variant.sku,
            'policy' => 'defer_to_components',
            'component_quantities' => variant.component_quantities
          )
        )

        inventory.destroy!
      else
        inventory.update!(component_quantities: variant.component_quantities)
      end
    end

    def update_fulfillment
      return unless sku_changed?

      fulfillment_sku = Fulfillment::Sku.find(original_sku) rescue nil
      fulfillment_sku.destroy! if fulfillment_sku.present?

      Fulfillment::Sku.create!(id: variant.sku, policy: 'bundle')
    end
  end
end
