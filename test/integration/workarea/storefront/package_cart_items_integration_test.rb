require 'test_helper'

module Workarea
  module Storefront
    class PackageCartItemsIntegrationTest < Workarea::IntegrationTest
      include Storefront::IntegrationTest

      def test_package
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

        post storefront.package_cart_items_path, params: {
          product_id: family_product.id,
          items: {
            '0' => {
              product_id: dwoos_product.id,
              sku: dwoos_sku,
              quantity: 1
            },
            '1' => {
              product_id: standard_product.id,
              sku: standard_sku,
              quantity: 1
            }
          }
        }
        skus_in_cart = Order.last.items.map(&:sku)

        assert_response(:success)
        assert_includes(skus_in_cart, standard_sku)
        refute_includes(skus_in_cart, dwoos_sku)
      end
    end
  end
end
