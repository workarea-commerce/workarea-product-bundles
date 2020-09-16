require 'test_helper'

module Workarea
  class Fulfillment
    module Policies
      class SkipTest < TestCase
        def test_process
          item = Order::Item.new
          fulfillment = Fulfillment.new(
            items: [{ order_item_id: item.id.to_s, quantity: 3 }]
          )

          Skip.new(nil).process(order_item: item, fulfillment: fulfillment)
          assert_equal(0, fulfillment.items.first.quantity)
        end
      end
    end
  end
end
