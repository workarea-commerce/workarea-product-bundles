module Workarea
  class UpdateKitInventory
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: {
        Catalog::Variant => :save,
        only_if: -> { components.present? },
        with: -> { [product.id, id] }
      },
      unique: :until_executing
    )

    def perform(product_id, id)
      product = Catalog::Product.find(product_id) rescue nil
      variant = product&.variants&.detect { |v| v.id.to_s == id.to_s }

      return unless variant.present?

      sku = Inventory::Sku.find_or_initialize_by(id: variant.sku)
      sku.update!(component_quantities: variant.component_quantities)
    end
  end
end
