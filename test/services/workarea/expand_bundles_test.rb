require 'test_helper'

module Workarea
  class ExpandBundlesTest < TestCase
    def test_perform
      order = create_placed_order
      order.items.first.product_attributes['product_ids'] = %w(BUNDLE_1 BUNDLE_2)
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
            price_adjustments: [{ price: 'item', quantity: 2, amount: 3.to_m }],
          },
          {
            product_id: 'BUNDLED_2',
            sku: 'BSKU2',
            quantity: 1,
            bundle_quantity: 1,
            bundle_item_id: order.items.first.id.to_s,
            total_value: 2.to_m,
            total_price: 2.to_m,
            price_adjustments: [{ price: 'item', quantity: 1, amount: 2.to_m }]
          }
        ]
      )

      ExpandBundles.new(order).perform
      order.reload

      assert_equal(3, order.items.size)

      item = order.items.detect { |i| i.sku == 'SKU' }
      assert_equal(0.to_m, item.total_price)
      assert_equal(0.to_m, item.total_value)
      item.price_adjustments.each do |pa|
        assert_equal(0.to_m, pa.amount)
        assert(pa.data['distributed_to_bundled_items'])
        assert(pa.data['original_amount'].present?)
      end

      assert_includes(order.items.map(&:sku), 'BSKU1')
      assert_includes(order.items.map(&:sku), 'BSKU2')
    end
  end
end
