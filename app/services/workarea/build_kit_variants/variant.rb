module Workarea
  class BuildKitVariants
    class Variant
      attr_reader :builder, :components, :pricing_sku, :inventory_sku, :fulfillment_sku
      delegate :sku, :details, to: :model
      delegate :product, :params, :next_variant_sku, :pricing, to: :builder
      delegate :calculate_pricing?, :custom_price, :new_details?, :new_details, to: :params

      def initialize(builder, components)
        @builder = builder
        @components = components
      end

      def build
        return @result if defined?(@result)

        build_details
        build_components
        build_pricing
        build_inventory
        build_fulfillment

        @result =
          model.valid? &&
          pricing_sku.valid? &&
          inventory_sku.valid? &&
          fulfillment_sku.valid?
      end

      def save!
        build && inventory_sku.save! && pricing_sku.save! && fulfillment_sku.save!
      end

      def model
        @model ||= product.variants.build(sku: next_variant_sku)
      end

      def has_details?
        defined?(@result) ? details.present? : component_details.present?
      end

      def invalid_details?
        details.values.any?(&:many?)
      end

      def status
        if !defined?(@result)
          :unbuilt
        elsif @result
          :built
        else
          :failed_to_build
        end
      end

      def inventory_sku=(sku)
        @inventory_sku = sku
      end

      def pricing_sku=(sku)
        @pricing_sku = sku
      end

      def fulfillment_sku=(sku)
        @fulfillment_sku = sku
      end

      private

      def build_pricing
        pricing_data = component_pricing
        @pricing_sku ||= Pricing::Sku.find_or_initialize_by(id: sku)

        @pricing_sku.msrp = pricing_data[:msrp] if pricing_data[:msrp].positive?
        @pricing_sku.tax_code = pricing_data[:tax_codes].compact.uniq.first

        price = @pricing_sku.active_prices.first || @pricing_sku.prices.build
        price.regular =
          calculate_pricing? ? pricing_data[:regular] : custom_price.to_m
      end

      def build_details
        model.details = component_details

        if new_details?
          model.details = HashUpdate.new(
            original: details,
            adds: new_details,
          ).result
        end
      end

      def build_components
        components.each do |component_params|
          matching_component = model.components.detect do |component|
            component.product_id == component_params[:product_id] &&
            component.sku == component_params[:sku]
          end

          if matching_component.present?
            matching_component.quantity += component_params[:quantity].to_i
          else
            model.components.build(
              component_params.slice(:product_id, :sku, :quantity)
            )
          end
        end
      end

      def build_inventory
        @inventory_sku ||= Inventory::Sku.find_or_initialize_by(id: sku)
        @inventory_sku.assign_attributes(
          policy: 'defer_to_components',
          component_quantities: model.component_quantities
        )
      end

      def build_fulfillment
        @fulfillment_sku ||= Fulfillment::Sku.find_or_initialize_by(id: sku)
        @fulfillment_sku.assign_attributes(policy: 'skip')
      end

      def component_pricing
        price_hash = Hash.new(0.to_m).tap { |h| h[:tax_codes] = [] }

        components.each_with_object(price_hash) do |component, hash|
          record = pricing.detect { |r| r.id == component[:sku] }
          next unless record.present?

          price = record.find_price

          hash[:tax_codes] << record.tax_code
          hash[:msrp] += record.msrp.to_m
          hash[:regular] += price.regular.to_m
        end
      end

      def component_details
        components.each_with_object({}) do |component, hash|
          component[:details].each do |key, value|
            hash[key] = ((hash[key] || []) + value).uniq
          end
        end
      end
    end
  end
end
