require 'test_helper'

module Workarea
  module Storefront
    class CategoriesWithPackagesSystemTest < Workarea::SystemTest
      include Storefront::SystemTest

      setup :set_products
      setup :update_search_settings

      def set_products
        @products ||= [
          create_product(id:          'PROD1',
                         name:        'Integration Product 1',
                         filters:     { 'Size' => 'Medium', 'Color' => %w(Green Red) },
                         created_at:  Time.now - 1.hour,
                         variants:    [{ sku: 'SKU1', regular: 10.to_m }]),
          create_product(id:          'PROD2',
                         name:        'Integration Product 2',
                         filters:     { 'Size' => %w(Medium Small), 'Color' => 'Red' },
                         created_at:  Time.now - 2.hour,
                         variants:    [{ sku: 'SKU2', regular: 5.to_m, details: { 'Size' => 'Medium' } },
                                       { sku: 'SKU4', regular: 5.to_m, details: { 'Size' => 'Large' } }]),
          create_product(id:       'PROD3',
                         name:     'Integration Product 3',
                         filters:  { 'Size' => %w(Medium Small), 'Color' => 'Blue' },
                         created_at: Time.now - 3.hour,
                         variants: [{ sku: 'SKU3', regular: 5.to_m }]),
          create_product(id:       'PROD4',
                         name:     'Integration Package Product 1',
                         template: 'package',
                         filters:  { 'Size' => ['Small', 'Medium', 'Large', 'Extra Large'], 'Color' => %w(Red Green) },
                         created_at: Time.now - 4.hour,
                         product_ids: %w(PROD1 PROD2 PROD3))
        ]
      end

      def categorize_products(category)
        category.update_attributes!(
          product_ids: [@products.second.id, @products.first.id, @products.fourth.id]
        )
      end

      def test_basic_category_setup
        category = create_category
        categorize_products(category)

        visit storefront.category_path(category)

        assert(page.has_content?('Integration Product 1'))
        assert(page.has_content?('Integration Product 2'))
        assert(page.has_content?('Integration Package Product 1'))
        assert(page.has_content?('$10.00'))
        assert(page.has_content?('$5.00'))
        assert(page.has_content?('Medium (3)'))
        assert(page.has_content?('Small (2)'))
      end

      def test_sorting_products
        category = create_category
        categorize_products(category)

        visit storefront.category_path(category)

        select('Price, Low to High', from: 'sort_top')
        assert(page.has_ordered_text?(
                 'Integration Product 2',
                 'Integration Package Product',
                 'Integration Product 1'
        ))

        visit storefront.category_path(category)
        select('Price, High to Low', from: 'sort_top')
        assert(page.has_ordered_text?(
                 'Integration Product 1',
                 'Integration Product 2',
                 'Integration Package Product'
        ))

        visit storefront.category_path(category)
        select('Newest', from: 'sort_top')
        assert(page.has_ordered_text?(
                 'Integration Product 1',
                 'Integration Product 2',
                 'Integration Package Product'
        ))

        create_product_by_week(product_id: 'PROD2', orders: 3)
        create_product_by_week(product_id: 'PROD1', orders: 1)
        create_product_by_week(product_id: 'PROD3', orders: 2)
        BulkIndexProducts.perform_by_models(@products)

        visit storefront.category_path(category)
        select('Top Sellers', from: 'sort_top')
        assert(page.has_ordered_text?(
                 'Integration Product 2',
                 'Integration Package Product',
                 'Integration Product 1'
        ))
      end

      def test_package_out_of_stock
        category = create_category
        categorize_products(category)

        create_inventory(id: 'SKU',  policy: 'standard', available: 0)
        create_inventory(id: 'SKU1', policy: 'standard', available: 0)
        create_inventory(id: 'SKU2', policy: 'standard', available: 0)
        create_inventory(id: 'SKU3', policy: 'standard', available: 0)
        create_inventory(id: 'SKU4', policy: 'standard', available: 0)

        visit storefront.category_path(category)

        assert(page.has_no_content?('Integration Product 1'))
        assert(page.has_no_content?('Integration Product 2'))
        assert(page.has_no_content?('Integration Package Product 1'))
      end

      def test_filtering_products
        category = create_category
        categorize_products(category)

        visit storefront.category_path(category)

        Capybara.match = :first
        click_link '$10.00 - $19.99 (2)'

        assert(page.has_content?('Integration Product 1'))
        assert(page.has_no_content?('Integration Product 2'))
        assert(page.has_content?('Integration Package Product 1'))

        click_link '$10.00 - $19.99 (remove)'

        assert(page.has_content?('Integration Product 1'))
        assert(page.has_content?('Integration Product 2'))
        assert(page.has_content?('Integration Package Product 1'))

        click_link 'Extra Large (1)'

        assert(page.has_content?('Integration Package Product 1'))
        assert(page.has_no_content?('Integration Product 1'))
        assert(page.has_no_content?('Integration Product 2'))

        click_link 'Extra Large (remove)'

        assert(page.has_content?('Integration Product 1'))
        assert(page.has_content?('Integration Product 2'))
        assert(page.has_content?('Integration Package Product 1'))
      end

      def test_product_filtering_and_sorting
        category = create_category
        categorize_products(category)

        visit storefront.category_path(category)

        Capybara.match = :first
        click_link '$10.00 - $19.99 (2)'

        assert(page.has_content?('Integration Product 1'))
        assert(page.has_no_content?('Integration Product 2'))
        assert(page.has_content?('Integration Package Product 1'))

        select('Price, Low to High', from: 'sort_top')

        assert(page.has_content?('Integration Product 1'))
        assert(page.has_no_content?('Integration Product 2'))
        assert(page.has_content?('Integration Package Product 1'))
      end
    end
  end
end
