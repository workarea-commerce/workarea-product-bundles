require 'test_helper'

module Workarea
  module Catalog
    class BundleVariantTest < TestCase
      def test_component_quantities
        variant = Catalog::Variant.new(
          components: [
            { sku: 'SKU1', quantity: 1 },
            { sku: 'SKU2', quantity: 2 },
            { sku: 'SKU3', quantity: 3 }
          ]
        )

        assert_equal(
          { 'SKU1' => 1, 'SKU2' => 2, 'SKU3' => 3 },
          variant.component_quantities
        )
      end

      def test_admin_filter_values
        variant = Catalog::Variant.new(
          sku: 'SKU001',
          details: { 'Color' => %w(red), 'Size' => %w(small) },
          components: [
            { product_id: 'PROD1', sku: 'SKU1', quantity: 1 },
            { product_id: 'PROD2', sku: 'SKU2', quantity: 2 },
            { product_id: 'PROD3', sku: 'SKU3', quantity: 3 }
          ]
        )

        assert_equal(
          'sku001 color red size small sku1 prod1 sku2 prod2 sku3 prod3',
          variant.admin_filter_value
        )
      end
    end
  end
end
