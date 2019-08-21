require 'test_helper'

module Workarea
  module Storefront
    class PackageProductSystemTest < Workarea::SystemTest
      include Storefront::SystemTest

      def test_showing_package_product
        packaged_products = [
          create_product(
            name: 'Packaged Product 1',
            variants: [
              { sku: 'SKU1', regular: 1.to_m },
              { sku: 'SKU2', regular: 2.to_m }
            ]
          ),
          create_product(
            name: 'Packaged Product 2',
            variants: [
              { sku: 'SKU3', regular: 3.to_m },
              { sku: 'SKU4', regular: 4.to_m }
            ]
          )
        ]

        package = create_product(
          name: 'Test Product',
          template: 'package',
          product_ids: packaged_products.map(&:id)
        )

        visit storefront.product_path(package)

        assert(page.has_content?('Test Product'))
        assert(page.has_content?('Packaged Product 1'))
        assert(page.has_content?('Packaged Product 2'))
        assert(page.has_content?('$1.00'))
        assert(page.has_content?('$3.00'))
      end
    end
  end
end
