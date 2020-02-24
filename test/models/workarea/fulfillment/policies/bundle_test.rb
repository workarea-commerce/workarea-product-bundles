require 'test_helper'

module Workarea
  class Fulfillment
    module Policies
      class BundleTest < TestCase
        def test_process
          item = Order::Item.new(
            product_attributes: { 'product_ids' => [1, 2] }
          )
          fulfillment = Fulfillment.new(
            items: [{ order_item_id: item.id.to_s, quantity: 3 }]
          )

          Bundle.new(nil).process(order_item: item, fulfillment: fulfillment)
          assert_equal(0, fulfillment.items.first.quantity)
        end
      end
    end
  end
end
