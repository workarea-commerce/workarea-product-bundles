require 'test_helper'

module Workarea
  module Storefront
    class KitProductSystemTest < Workarea::SystemTest
      include Storefront::SystemTest

      def test_adding_a_kit_product_to_cart
        bundled_products = [
          create_product(
            name: 'Kit Product 1',
            variants: [
              { sku: 'SKU1', regular: 1.to_m },
              { sku: 'SKU2', regular: 1.to_m }
            ]
          ),
          create_product(
            name: 'Kit Product 2',
            variants: [{ sku: 'SKU3', regular: 2.to_m }]
          ),
          create_product(
            name: 'Kit Product 3',
            variants: [{ sku: 'SKU4', regular: 3.to_m }]
          )
        ]

        kit = create_product(
          name: 'Test Product',
          product_ids: bundled_products.map(&:id),
          variants: [
            {
              sku: 'KIT1',
              regular: 4.to_m,
              components: [
                { product_id: bundled_products.first.id, sku: 'SKU1' },
                { product_id: bundled_products.second.id, sku: 'SKU3', quantity: 2 }
              ]
            },
            {
              sku: 'KIT2',
              regular: 4.to_m,
              components: [
                { product_id: bundled_products.first.id, sku: 'SKU2' },
                { product_id: bundled_products.last.id, sku: 'SKU4', quantity: 2 }
              ]
            }
          ]
        )

        visit storefront.product_path(kit)

        assert(page.has_content?('Test Product'))
        assert(page.has_content?('$4.00'))

        select 'KIT1', from: 'sku'

        within '.product-details-bundled-products' do
          assert(page.has_content?('Kit Product 1'))
          assert(page.has_content?('Kit Product 2'))
          assert(page.has_no_content?('Kit Product 3'))
        end

        select 'KIT2', from: 'sku'

        within '.product-details-bundled-products' do
          assert(page.has_content?('Kit Product 1'))
          assert(page.has_content?('Kit Product 3'))
          assert(page.has_no_content?('Kit Product 2'))
        end

        click_button t('workarea.storefront.products.add_to_cart')

        dialog = find('.ui-dialog')

        assert(dialog.has_content?('Success'))
        assert(dialog.has_content?(kit.name))
      end
    end
  end
end
