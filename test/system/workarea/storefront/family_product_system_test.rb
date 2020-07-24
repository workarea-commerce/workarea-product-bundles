require 'test_helper'

module Workarea
  module Storefront
    class FamilyProductSystemTest < Workarea::SystemTest
      include Storefront::SystemTest

      def test_adding_a_family_product_to_cart
        bundled_products = [
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

        family = create_product(
          name: 'Test Product',
          template: 'family',
          product_ids: bundled_products.map(&:id)
        )

        visit storefront.product_path(family)

        assert(page.has_content?('Test Product'))
        assert(page.has_content?('Packaged Product 1'))
        assert(page.has_content?('Packaged Product 2'))
        assert(page.has_content?('$1.00'))
        assert(page.has_content?('$3.00'))

        product_1 = bundled_products.first
        select product_1.variants.first.sku, from: "bundled_items__sku_catalog_product_#{product_1.id}"
        fill_in "bundled_items__quantity_catalog_product_#{product_1.id}", with: 1

        product_2 = bundled_products.second
        select product_2.variants.first.sku, from: "bundled_items__sku_catalog_product_#{product_2.id}"
        fill_in "bundled_items__quantity_catalog_product_#{product_2.id}", with: 1

        click_button t('workarea.storefront.products.add_to_cart')

        dialog = find('.ui-dialog')

        assert(dialog.has_content?('Success'))
        assert(dialog.has_content?(product_1.name))
        assert(dialog.has_content?(product_2.name))
      end
    end
  end
end
