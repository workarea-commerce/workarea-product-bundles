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
    end
  end
end
