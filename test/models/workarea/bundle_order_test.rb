require 'test_helper'

module Workarea
  class BundleOrderTest < TestCase
    setup :order

    def order
      @order ||= create_order(
        items: [
          {
            product_id: 'BUNDLE',
            sku: 'SKU',
            quantity: 1
          }
        ]
      )
    end

    def add_bundled_item_to_order
      order.update!(
        bundled_items: [{
          quantity: 1,
          product_id: 'BUNDLED_PROD',
          sku: 'BUNDLED_SKU',
          bundle_item_id: order.items.first.id.to_s,
          bundle_quantity: 1
        }]
      )
    end

    def test_add_bundled_item
      order.add_bundled_item(
        product_id: 'BUNDLED_PROD',
        sku: 'BUNDLED_SKU',
        bundle_item_id: order.items.first.id.to_s,
        bundle_quantity: 1
      )

      assert_equal(1, order.bundled_items.size)
      assert_equal('BUNDLED_SKU', order.bundled_items.first.sku)
      assert_equal(order.items.first.id.to_s, order.bundled_items.first.bundle_item_id)
      assert_equal(1, order.bundled_items.first.quantity)
      assert_equal(1, order.bundled_items.first.bundle_quantity)

      order.add_bundled_item(
        product_id: 'BUNDLED_PROD',
        sku: 'BUNDLED_SKU',
        bundle_item_id: order.items.first.id.to_s,
        bundle_quantity: 1
      )

      assert_equal(1, order.bundled_items.size)
      assert_equal('BUNDLED_SKU', order.bundled_items.first.sku)
      assert_equal(order.items.first.id.to_s, order.bundled_items.first.bundle_item_id)
      assert_equal(2, order.bundled_items.first.quantity)
      assert_equal(1, order.bundled_items.first.bundle_quantity)
    end

    def test_update_bundled_item
      add_bundled_item_to_order

      order.update_bundled_item(
        order.bundled_items.first.id.to_s,
        quantity: 2,
        product_id: 'BUNDLED_PROD',
        sku: 'BUNDLED_SKU',
        bundle_item_id: order.items.first.id.to_s,
        bundle_quantity: 1
      )

      assert_equal(1, order.bundled_items.size)
      assert_equal('BUNDLED_SKU', order.bundled_items.first.sku)
      assert_equal(order.items.first.id.to_s, order.bundled_items.first.bundle_item_id)
      assert_equal(2, order.bundled_items.first.quantity)
      assert_equal(1, order.bundled_items.first.bundle_quantity)

      dup_item = order.bundled_items.create!(
        quantity: 1,
        product_id: 'BUNDLED_PROD',
        sku: 'BUNDLED_SKU',
        bundle_item_id: order.items.first.id.to_s,
        bundle_quantity: 1
      )

      order.update_bundled_item(
        dup_item.id.to_s,
        quantity: 1,
        product_id: 'BUNDLED_PROD',
        sku: 'BUNDLED_SKU',
        bundle_item_id: order.items.first.id.to_s,
        bundle_quantity: 1
      )

      assert_equal(1, order.bundled_items.size)
      assert_equal('BUNDLED_SKU', order.bundled_items.first.sku)
      assert_equal(order.items.first.id.to_s, order.bundled_items.first.bundle_item_id)
      assert_equal(3, order.bundled_items.first.quantity)
      assert_equal(1, order.bundled_items.first.bundle_quantity)
    end

    def test_remove_bundled_item
      add_bundled_item_to_order

      order.remove_bundled_item(order.bundled_items.first.id)
      assert_equal(0, order.bundled_items.size)
    end

    def test_sku_quantities
      add_bundled_item_to_order
      order.bundled_items.first.quantity = 2

      assert_equal(
        { 'SKU' => 1, 'BUNDLED_SKU' => 2 },
        order.sku_quantities
      )
    end

    def test_update_bundled_items
      add_bundled_item_to_order
      order.items.first.update!(product_attributes: { 'product_ids' => [1, 2] })
      order.bundled_items.first.update!(quantity: 2, bundle_quantity: 2)

      order.reload
      order.items.first.quantity = 2
      order.save!
      assert_equal(4, order.bundled_items.first.quantity)
      assert_equal(2, order.bundled_items.first.bundle_quantity)

      order.reload
      order.items.first.quantity = 1
      order.save!
      assert_equal(2, order.bundled_items.first.quantity)
      assert_equal(2, order.bundled_items.first.bundle_quantity)
    end

    def test_clean_bundled_items
      add_bundled_item_to_order

      assert_equal(1, order.bundled_items.size)

      order.update!(items: [])

      assert_equal(0, order.bundled_items.size)
    end
  end
end
