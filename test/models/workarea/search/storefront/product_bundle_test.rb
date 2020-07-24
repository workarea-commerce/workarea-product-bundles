require 'test_helper'

module Workarea
  module Search
    class Storefront
      class ProductBundleTest < TestCase
        def bundled_products
          @bundled_products ||= [
            create_product(variants: [{ sku: 'SKU1' }]),
            create_product(variants: [{ sku: 'SKU2' }]),
            create_product(variants: [{ sku: 'SKU3' }])
          ]
        end

        def product
          @product ||= Catalog::Product.new(
            product_ids: bundled_products.map(&:id)
          )
        end

        def search_model
          @search_model ||= ProductBundle.new(product)
        end

        def test_skus
          assert_equal(3, search_model.skus.length)
          assert_includes(search_model.skus, 'SKU1')
          assert_includes(search_model.skus, 'SKU2')
          assert_includes(search_model.skus, 'SKU3')
        end

        def test_variant_count
          assert_equal(3, search_model.variant_count)
        end

        def test_bundled_products_handles_nonexistent_ids
          product.product_ids << 'foo'

          assert_equal(3, search_model.send(:bundled_products).size)
        end
      end
    end
  end
end
