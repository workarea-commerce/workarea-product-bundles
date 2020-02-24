require 'test_helper'

module Workarea
  module Pricing
    class BundleAdjustmentsTest < TestCase
      def test_adjust
        order = create_order(
          items: [
            {
              product_id: 'PROD',
              sku: 'SKU',
              quantity: 1,
              total_price: 8.to_m,
              total_value: 8.to_m,
              product_attributes: { 'product_ids' => %w(BUNDLE_1 BUNDLE_2) },
              price_adjustments: [
                { price: 'item', quantity: 1, amount: 11.to_m, description: 'Subtotal' },
                { price: 'item', quantity: 1, amount: -3.to_m, description: 'Discount' },
                { price: 'tax', quantity: 1, amount: 1.to_m, description: 'Tax' }
              ]
            }
          ]
        )

        order.update!(
          bundled_items: [
            {
              product_id: 'BUNDLED_1',
              sku: 'BSKU1',
              quantity: 2,
              bundle_quantity: 2,
              bundle_item_id: order.items.first.id.to_s,
              total_value: 3.to_m,
              total_price: 3.to_m,
              price_adjustments: [{ price: 'item', quantity: 2, amount: 10.to_m }],
            },
            {
              product_id: 'BUNDLED_2',
              sku: 'BSKU2',
              quantity: 1,
              bundle_quantity: 1,
              bundle_item_id: order.items.first.id.to_s,
              total_value: 2.to_m,
              total_price: 2.to_m,
              price_adjustments: [{ price: 'item', quantity: 1, amount: 5.to_m }]
            }
          ]
        )

        BundleAdjustments.new(order).adjust

        item = order.bundled_items.detect { |i| i.sku == 'BSKU1' }
        assert_equal(4, item.price_adjustments.size)
        assert_equal(-2.67.to_m, item.price_adjustments.second.amount)
        assert_equal('Bundle Adjustment', item.price_adjustments.second.description)
        assert_equal(-2.to_m, item.price_adjustments.third.amount)
        assert_equal('Discount', item.price_adjustments.third.description)
        assert_equal(0.66.to_m, item.price_adjustments.fourth.amount)
        assert_equal('Tax', item.price_adjustments.fourth.description)

        item = order.bundled_items.detect { |i| i.sku == 'BSKU2' }
        assert_equal(4, item.price_adjustments.size)
        assert_equal(-1.33.to_m, item.price_adjustments.second.amount)
        assert_equal('Bundle Adjustment', item.price_adjustments.second.description)
        assert_equal(-1.to_m, item.price_adjustments.third.amount)
        assert_equal('Discount', item.price_adjustments.third.description)
        assert_equal(0.34.to_m, item.price_adjustments.fourth.amount)
        assert_equal('Tax', item.price_adjustments.fourth.description)

        assert_equal(order.items.first.total_value, order.bundled_items.sum(&:total_value))
        assert_equal(order.items.first.total_price, order.bundled_items.sum(&:total_price))
      end
    end
  end
end
