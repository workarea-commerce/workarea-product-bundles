require 'test_helper'
module Workarea
  module Catalog
    class ProductBundleTest < TestCase
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

      def test_bundles_containing
        results = Product.bundles_containing('PROD1')
        assert_equal([@package], results)
      end

      def test_bundle?
        @product_one.template = 'package'
        refute(@product_one.bundle?)

        @product_one.product_ids = [1, 2]
        assert(@product_one.bundle?)
      end

      def test_package?
        refute(@product_one.package?)

        @product_one.template = 'package'
        refute(@product_one.package?)

        @product_one.product_ids = [1, 2]
        assert(@product_one.package?)
      end

      def test_family?
        refute(@product_one.family?)

        @product_one.template = 'family'
        refute(@product_one.family?)

        @product_one.product_ids = [1, 2]
        assert(@product_one.family?)
      end

      def test_kit?
        refute(@product_one.kit?)

        @product_one.product_ids = [1, 2]
        refute(@product_one.kit?)

        @product_one.variants.each do |variant|
          variant.components = [{ sku: 'BUNDLED1' }]
        end
        assert(@product_one.kit?)
      end

      def test_discrete_bundle?
        @product_one.product_ids = [1, 2]
        refute(@product_one.discrete_bundle?)

        @product_one.template = 'kit'
        refute(@product_one.discrete_bundle?)

        @product_one.template = 'package'
        assert(@product_one.discrete_bundle?)

        @product_one.template = 'family'
        assert(@product_one.discrete_bundle?)
      end

      def test_active?
        @product_one.active = true
        assert(@product_one.active?)

        @product_one.variants.clear
        refute(@product_one.active?)

        packaged_one = create_product(active: true)
        packaged_two = create_product(active: false)

        @product_one.product_ids = [packaged_one.id]
        assert(@product_one.active?)

        @product_one.product_ids = [packaged_one.id, packaged_two.id]
        assert(@product_one.active?)

        @product_one.product_ids = [packaged_two.id]
        refute(@product_one.active?)
      end
    end
  end
end
