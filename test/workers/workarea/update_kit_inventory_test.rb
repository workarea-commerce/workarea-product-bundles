require 'test_helper'

module Workarea
  class UpdateKitInventoryTest < TestCase
    def test_perform
      product = create_product(
        variants: [{
            sku: 'SKU',
            components: [
              { sku: 'BSKU1', quantity: 1 },
              { sku: 'BSKU2', quantity: 2 },
            ]
        }]
      )

      UpdateKitInventory
        .new
        .perform(product.id.to_s, product.variants.first.id.to_s)

      inventory = Inventory::Sku.find('SKU')
      assert_equal({ 'BSKU1' => 1, 'BSKU2' => 2 }, inventory.component_quantities)

      product.variants.first.update!(
        components: [
          { sku: 'BSKU1', quantity: 2 },
          { sku: 'BSKU2', quantity: 4 },
        ]
      )

      UpdateKitInventory
        .new
        .perform(product.id.to_s, product.variants.first.id.to_s)

      inventory = Inventory::Sku.find('SKU')
      assert_equal({ 'BSKU1' => 2, 'BSKU2' => 4 }, inventory.component_quantities)
    end
  end
end
