module Workarea
  class Fulfillment
    module Policies
      class Skip < Base
        # Bundles themselves will not need to be fulfilled. The items contained
        # within the bundle will be added to Fulfillment and processed
        # separately. This policy sets the item for the bundle to 0.
        def process(order_item:, fulfillment: nil)
          return unless fulfillment.present?

          fulfillment_item =
            fulfillment.items.detect do |item|
              item.order_item_id.to_s == order_item.id.to_s
            end

          fulfillment_item.quantity = 0 if fulfillment_item.present?
        end
      end
    end
  end
end
