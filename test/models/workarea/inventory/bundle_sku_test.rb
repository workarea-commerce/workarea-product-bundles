require 'test_helper'

module Workarea
  module Inventory
    class BundleSkuTest < TestCase
      def test_component_inventory
        sku = create_inventory
        assert_equal([], sku.component_inventory)

        sku.update!(component_quantities: { 'BSKU1' => 1, 'BSKU2' => 2 })
        assert_equal([], sku.component_inventory)

        component_sku_1 = create_inventory(id: 'BSKU1')
        component_sku_2 = create_inventory(id: 'BSKU2')

        assert_includes(sku.component_inventory, component_sku_1)
        assert_includes(sku.component_inventory, component_sku_2)
      end
    end
  end
end
