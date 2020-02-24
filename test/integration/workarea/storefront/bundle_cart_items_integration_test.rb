require 'test_helper'

module Workarea
  module Storefront
    class BundleCartItemsIntegrationTest < Workarea::IntegrationTest
      include Storefront::IntegrationTest

      def test_create_with_bundled_items
        inventory = create_inventory(
          id: 'SKU1',
          policy: 'standard',
          available: 2
        )
        inventory = create_inventory(
          id: 'SKU2',
          policy: 'standard',
          available: 2
        )

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


        post storefront.cart_items_path,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 1,
            bundled_items: [
              { product_id: bundled_product_1.id, sku: 'SKU1', quantity: 1 },
              { product_id: bundled_product_2.id, sku: 'SKU2', quantity: 2 },
            ]
          }

        assert(response.ok?)

        order = Order.first
        assert_equal(product.id, order.items.first.product_id)
        assert_equal(product.skus.first, order.items.first.sku)
        assert_equal(1, order.items.first.quantity)
        assert_equal(9.to_m, order.items.first.total_price)

        assert_equal(2, order.bundled_items.size)
        assert_equal(bundled_product_1.id, order.bundled_items.first.product_id)
        assert_equal(bundled_product_1.skus.first, order.bundled_items.first.sku)
        assert_equal(1, order.bundled_items.first.quantity)
        assert_equal(bundled_product_2.id, order.bundled_items.last.product_id)
        assert_equal(bundled_product_2.skus.first, order.bundled_items.last.sku)
        assert_equal(2, order.bundled_items.last.quantity)
      end

      def test_bundle
        dwoos_product = create_product(variants: [{ sku: 'DWOOS1' }])
        create_inventory(
          id: dwoos_product.skus.first,
          policy: 'displayable_when_out_of_stock',
          available: 0
        )
        standard_product = create_product
        create_inventory(id: standard_product.skus.first)
        family_product = create_product(
          template: 'family',
          product_ids: [dwoos_product.id, standard_product.id]
        )

        dwoos_sku = dwoos_product.skus.first
        standard_sku = standard_product.skus.first

        post storefront.bundle_cart_items_path, params: {
          product_id: family_product.id,
          bundled_items: [
            {
              product_id: dwoos_product.id,
              sku: dwoos_sku,
              quantity: 1
            },
            {
              product_id: standard_product.id,
              sku: standard_sku,
              quantity: 1
            }
          ]
        }

        skus_in_cart = Order.last.items.map(&:sku)

        assert_response(:success)
        assert_includes(skus_in_cart, standard_sku)
        refute_includes(skus_in_cart, dwoos_sku)
      end
    end
  end
end
