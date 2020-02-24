require 'test_helper'

module Workarea
  module Inventory
    module Policies
      class DeferToComponentsTest < TestCase
        def test_available_to_sell
          sku = create_inventory(
            id: 'SKU',
            policy: 'defer_to_components',
            available: 5,
            component_quantities: { 'BSKU1' => 1, 'BSKU2' => 2 }
          )
          component_sku_1 = create_inventory(id: 'BSKU1', policy: 'standard', available: 5)
          component_sku_2 = create_inventory(id: 'BSKU2', policy: 'standard', available: 5)

          policy = DeferToComponents.new(sku)
          assert_equal(2, policy.available_to_sell)

          component_sku_2.update!(available: 6)

          policy = DeferToComponents.new(sku)
          assert_equal(3, policy.available_to_sell)
        end
      end
    end
  end
end
