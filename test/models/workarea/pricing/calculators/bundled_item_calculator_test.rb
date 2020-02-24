require 'test_helper'

module Workarea
  module Pricing
    module Calculators
      class BundledItemCalculatorTest < TestCase
        def test_adjust
          order = Order.new(
            bundled_items: [
              { sku: 'BSKU1', quantity: 1 },
              { sku: 'BSKU2', quantity: 2 }
            ]
          )

          create_pricing_sku(id: 'BSKU1', prices: [{ regular: 5.to_m }])
          create_pricing_sku(id: 'BSKU2', prices: [{ regular: 3.to_m }])

          BundledItemCalculator.test_adjust(order)

          item = order.bundled_items.detect { |i| i.sku == 'BSKU1' }
          assert_equal(1, item.price_adjustments.size)
          assert_equal(1, item.price_adjustments.first.quantity)
          assert_equal(5.to_m, item.price_adjustments.first.amount)

          item = order.bundled_items.detect { |i| i.sku == 'BSKU2' }
          assert_equal(1, item.price_adjustments.size)
          assert_equal(2, item.price_adjustments.first.quantity)
          assert_equal(6.to_m, item.price_adjustments.first.amount)
        end
      end
    end
  end
end
