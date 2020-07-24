module Workarea
  module Storefront
    module ItemBundles
      def bundled_items_for(item_id)
        bundled_items.select { |i| i.bundle_item_id == item_id.to_s }
      end
    end
  end
end
