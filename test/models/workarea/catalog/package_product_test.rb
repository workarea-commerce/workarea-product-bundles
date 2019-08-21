require 'test_helper'
module Workarea
  module Catalog
    # TODO: change to ProductTest decorator after base test is converted
    class PackageProductTest < TestCase
      setup :set_products

      def set_products
        @product_one = create_product(id: 'PROD1', variants: [{ sku: 'SKU1' }, { sku: 'SKU2' }])
        @product_two = create_product(id: 'PROD2', variants: [{ sku: 'SKU3' }])
        @product_three = create_product(id: 'PROD3', variants: [{ sku: 'SKU4' }])
        @package = create_product(id: 'PACK', template: 'package', product_ids: %w(PROD1 PROD2), variants: [])
      end

      def test_validations
        @package.product_ids << ''
        assert_equal(3, @package.product_ids.count)
        @package.save

        assert_equal(2, @package.product_ids.count)
        assert_equal(%w(PROD1 PROD2), @package.product_ids)
      end

      def test_find_for_update_by_sku
        results = Product.find_for_update_by_sku('SKU4')
        assert_equal([@product_three], results)

        results = Product.find_for_update_by_sku('SKU1')
        assert_equal([@product_one, @package], results)
      end

      def test_packages_containing
        results = Product.packages_containing('PROD1')
        assert_equal([@package], results)
      end

      def test_package?
        @product_one.template = 'package'
        assert(@product_one.package?)

        @product_one.template = 'generic'
        @product_one.product_ids = [1, 2]
        assert(@product_one.package?)

        @product_one.product_ids = []
        refute(@product_one.package?)
      end

      def test_family?
        @product_one.template = 'family'
        assert(@product_one.family?)
      end

      def test_active?
        @product_one.active = true
        @product_one.variants.clear

        refute(@product_one.active?)

        @product_one.active = true
        @product_one.product_ids = [1, 2]
        @product_one.variants.clear

        assert(@product_one.active?)
      end
    end
  end
end
