require 'test_helper'

module Workarea
  class UpdateKitVariantTest < TestCase
    def test_perform
      product = create_product(
        variants: [{
            sku: 'SKU1',
            details: { 'Color' => %w(red), 'Size' => %(large) },
            components: [
              { product_id: 'KP001', sku: 'KP001-1', quantity: 1 },
              { product_id: 'KP002', sku: 'KP002-1', quantity: 2 },
            ],
            regular: 5.to_m
        }]
      )

      variant = product.variants.first
      pricing = Pricing::Sku.find(variant.sku)
      inventory = Inventory::Sku.find_or_create_by(id: variant.sku)
      fulfillment = Fulfillment::Sku.find_or_create_by(id: variant.sku)

      update = UpdateKitVariant.new(
        variant,
        {
          original_sku: 'SKU1',
          variant: { sku: 'KV001' },
          new_details: ['Season', 'summer', '', ''],
          details: ['Color', 'Red', 'Size', 'medium'],
          details_to_remove: ['Color'],
          components: [
            { id: variant.components.first.id.to_s, remove: 'true' },
            { id: variant.components.second.id.to_s, quantity: 3 },
            { product_id: 'KP003', sku: 'KP003-1', quantity: 2 }
          ],
          pricing: { regular: 10.to_m, tax_code: '001' }
        }
      )

      assert(update.perform)

      assert_equal('KV001', variant.sku)

      assert_equal(
        { 'Size' => %w(medium), 'Season' => %w(summer) },
        variant.details
      )

      component = variant.components.detect { |c| c.sku == 'KP001-1' }
      refute(component.present?)

      component = variant.components.detect { |c| c.sku == 'KP002-1' }
      assert(component.present?)
      assert_equal(3, component.quantity)

      component = variant.components.detect { |c| c.sku == 'KP003-1' }
      assert(component.present?)
      assert_equal(2, component.quantity)

      assert_raises(Mongoid::Errors::DocumentNotFound) { pricing.reload }

      pricing = Pricing::Sku.find(variant.sku)
      assert_equal('001', pricing.tax_code)
      assert_equal(10.to_m, pricing.sell_price)

      assert_raises(Mongoid::Errors::DocumentNotFound) { inventory.reload }

      inventory = Inventory::Sku.find(variant.sku)
      assert_equal('defer_to_components', inventory.policy)
      assert_equal(
        { 'KP002-1' => 3, 'KP003-1' => 2 },
        inventory.component_quantities
      )

      assert_raises(Mongoid::Errors::DocumentNotFound) { fulfillment.reload }

      fulfillment = Fulfillment::Sku.find(variant.sku)
      assert_equal('skip', fulfillment.policy)
    end
  end
end
