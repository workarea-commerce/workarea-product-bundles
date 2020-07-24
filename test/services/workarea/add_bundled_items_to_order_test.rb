require 'test_helper'

module Workarea
  class AddBundledItemsToOrderTest < TestCase
    def test_perform
      bundled_product_1 = create_product(variants: [{ sku: 'SKU1', regular: 5.to_m }])
      bundled_product_2 = create_product(variants: [{ sku: 'SKU2', regular: 2.to_m }])

      product = create_product(
        name: 'Integration Product',
        variants: [
          {
            sku: 'BUNDLE1',
            regular: 9.to_m,
            components: [
              { sku: 'SKU1', product_id: bundled_product_1.id, quantity: 1 },
              { sku: 'SKU2', product_id: bundled_product_2.id, quantity: 2 }
            ]
          }
        ]
      )

      order = create_order(items: [{ product_id: product.id, sku: 'BUNDLE1', quantity: 2 }])
      item = order.items.first

      AddBundledItemsToOrder.new(
        order,
        item,
        [
          { product_id: bundled_product_1.id, sku: 'SKU1', quantity: 1 },
          { product_id: bundled_product_2.id, sku: 'SKU2', quantity: 2 },
        ]
      ).perform

      assert_equal(2, order.bundled_items.size)
      assert_equal(bundled_product_1.id, order.bundled_items.first.product_id)
      assert_equal(bundled_product_1.skus.first, order.bundled_items.first.sku)
      assert_equal(2, order.bundled_items.first.quantity)
      assert_equal(1, order.bundled_items.first.bundle_quantity)
      assert_equal(item.id.to_s, order.bundled_items.first.bundle_item_id.to_s)

      assert_equal(bundled_product_2.id, order.bundled_items.last.product_id)
      assert_equal(bundled_product_2.skus.first, order.bundled_items.last.sku)
      assert_equal(4, order.bundled_items.last.quantity)
      assert_equal(2, order.bundled_items.last.bundle_quantity)
      assert_equal(item.id.to_s, order.bundled_items.last.bundle_item_id.to_s)
    end
  end
end
