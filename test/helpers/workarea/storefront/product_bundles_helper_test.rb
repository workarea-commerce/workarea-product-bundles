require 'test_helper'

module Workarea
  module Storefront
    class ProductBundlesHelperTest < ViewTest
      def test_bundle_field_prefix
        product = create_product
        assert_equal('foo', bundle_field_prefix(product, 'foo'))

        product.product_ids = ['123']
        assert_equal('bundled_items[][foo]', bundle_field_prefix(product, 'foo'))

        product.template = 'package'
        assert_equal('foo', bundle_field_prefix(product, 'foo'))
      end

      def test_bundle_name_prefix
        product = create_product
        assert_equal('foo', bundle_name_prefix(product, 'foo'))

        product.product_ids = ['123']
        assert_equal('bundled_items__foo', bundle_name_prefix(product, 'foo'))

        product.template = 'package'
        assert_equal('foo', bundle_name_prefix(product, 'foo'))
      end
    end
  end
end
