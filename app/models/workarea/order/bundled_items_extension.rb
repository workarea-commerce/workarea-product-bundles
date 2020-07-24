module Workarea
  class Order
    module BundledItemsExtension
      def find_existing(sku, bundle_item_id, customizations = {})
        customizations.stringify_keys! if customizations.present?

        detect do |item|
          item.sku == sku &&
            item.bundle_item_id == bundle_item_id.to_s &&
              item.customizations_eql?(customizations)
        end
      end

      def find_for_bundle_item_id(id)
        select { |item| item.bundle_item_id.to_s == id.to_s }
      end
    end
  end
end
