require 'test_helper'

module Workarea
  class BuildKitVariantsTest < TestCase
    setup :supporting_data, :params

    def supporting_data
      create_product(
        id: 'PROD1',
        variants: [
          {
            sku: 'SKU1-1',
            regular: 5.to_m,
            details: { 'Color' => %w(Blue), 'Size' => %w(Small) }
          },
          {
            sku: 'SKU1-2',
            regular: 6.to_m,
            details: { 'Color' => %w(Blue), 'Size' => %w(Medium) }
          }
        ]
      )

      create_product(
        id: 'PROD2',
        variants: [
          {
            sku: 'SKU2-1',
            regular: 10.to_m,
            details: { 'Color' => %w(White), 'Material' => %w(Cotton) }
          },
          {
            sku: 'SKU2-2',
            regular: 12.to_m,
            details: { 'Color' => %w(Red), 'Material' => %w(Cotton) }
          }
        ]
      )

      Pricing::Sku.find('SKU1-1').update!(tax_code: '001')
      Pricing::Sku.find('SKU2-1').update!(tax_code: '002')
    end

    def params
      @params ||= {
        components: {
          '1' => [
            { selected: 'true', product_id: 'PROD1', sku: 'SKU1-1', quantity: '2' },
            { selected: 'true', product_id: 'PROD1', sku: 'SKU1-2', quantity: '2' },
            { selected: 'false', product_id: 'PROD1', sku: 'SKU1-3', quantity: '2' },
          ],
          '2' => [
            { selected: 'true', product_id: 'PROD2', sku: 'SKU2-1', quantity: '1' },
            { selected: 'true', product_id: 'PROD2', sku: 'SKU2-2', quantity: '1' },
            { selected: 'false', product_id: 'PROD2', sku: 'SKU2-3', quantity: '1' },
          ],
        },
        variant: {
          sku: 'KP',
          copy_options: 'true',
          calculate_pricing: 'true',
        }
      }
    end

    def test_perform
      kit = create_product(
        name: 'Test Kit',
        variants: [],
        product_ids: %w(PROD1 PROD2)
      )

      results = BuildKitVariants.new(kit, params).perform
      assert(results)

      assert_equal(4, kit.variants.size)

      variant = kit.variants.detect do |variant|
        skus = variant.components.map(&:sku)
        skus.include?('SKU1-1') && skus.include?('SKU2-1')
      end

      assert(variant.present?)
      assert_includes(variant.sku, 'KP-')
      assert_equal(%w(Blue White), variant.details['Color'])
      assert_equal(%w(Small), variant.details['Size'])
      assert_equal(%w(Cotton), variant.details['Material'])

      component = variant.components.detect { |c| c.sku == 'SKU1-1' }
      assert_equal(2, component.quantity)

      component = variant.components.detect { |c| c.sku == 'SKU2-1' }
      assert_equal(1, component.quantity)

      pricing = Pricing::Sku.find(variant.sku)
      assert_equal(15.to_m, pricing.sell_price)
      assert_equal('001', pricing.tax_code)

      inventory = Inventory::Sku.find(variant.sku)
      assert_equal('defer_to_components', inventory.policy)
      assert_equal({ 'SKU1-1' => 2, 'SKU2-1' => 1 }, inventory.component_quantities)

      fulfillment = Fulfillment::Sku.find(variant.sku)
      assert_equal('bundle', fulfillment.policy)

      variant = kit.variants.detect do |variant|
        skus = variant.components.map(&:sku)
        skus.include?('SKU1-1') && skus.include?('SKU2-2')
      end

      assert(variant.present?)
      assert_includes(variant.sku, 'KP-')
      assert_equal(%w(Blue Red), variant.details['Color'])
      assert_equal(%w(Small), variant.details['Size'])
      assert_equal(%w(Cotton), variant.details['Material'])

      component = variant.components.detect { |c| c.sku == 'SKU1-1' }
      assert_equal(2, component.quantity)

      component = variant.components.detect { |c| c.sku == 'SKU2-2' }
      assert_equal(1, component.quantity)

      pricing = Pricing::Sku.find(variant.sku)
      assert_equal(17.to_m, pricing.sell_price)
      assert_equal('001', pricing.tax_code)

      inventory = Inventory::Sku.find(variant.sku)
      assert_equal('defer_to_components', inventory.policy)
      assert_equal({ 'SKU1-1' => 2, 'SKU2-2' => 1 }, inventory.component_quantities)

      fulfillment = Fulfillment::Sku.find(variant.sku)
      assert_equal('bundle', fulfillment.policy)

      variant = kit.variants.detect do |variant|
        skus = variant.components.map(&:sku)
        skus.include?('SKU1-2') && skus.include?('SKU2-2')
      end

      assert(variant.present?)
      assert_includes(variant.sku, 'KP-')
      assert_equal(%w(Blue Red), variant.details['Color'])
      assert_equal(%w(Medium), variant.details['Size'])
      assert_equal(%w(Cotton), variant.details['Material'])

      component = variant.components.detect { |c| c.sku == 'SKU1-2' }
      assert_equal(2, component.quantity)

      component = variant.components.detect { |c| c.sku == 'SKU2-2' }
      assert_equal(1, component.quantity)

      pricing = Pricing::Sku.find(variant.sku)
      assert_equal(18.to_m, pricing.sell_price)
      assert_nil(pricing.tax_code)

      inventory = Inventory::Sku.find(variant.sku)
      assert_equal('defer_to_components', inventory.policy)
      assert_equal({ 'SKU1-2' => 2, 'SKU2-2' => 1 }, inventory.component_quantities)

      fulfillment = Fulfillment::Sku.find(variant.sku)
      assert_equal('bundle', fulfillment.policy)

      variant = kit.variants.detect do |variant|
        skus = variant.components.map(&:sku)
        skus.include?('SKU1-2') && skus.include?('SKU2-1')
      end

      assert(variant.present?)
      assert_includes(variant.sku, 'KP-')
      assert_equal(%w(Blue White), variant.details['Color'])
      assert_equal(%w(Medium), variant.details['Size'])
      assert_equal(%w(Cotton), variant.details['Material'])

      component = variant.components.detect { |c| c.sku == 'SKU1-2' }
      assert_equal(2, component.quantity)

      component = variant.components.detect { |c| c.sku == 'SKU2-1' }
      assert_equal(1, component.quantity)

      pricing = Pricing::Sku.find(variant.sku)
      assert_equal(16.to_m, pricing.sell_price)
      assert_equal('002', pricing.tax_code)

      inventory = Inventory::Sku.find(variant.sku)
      assert_equal('defer_to_components', inventory.policy)
      assert_equal({ 'SKU1-2' => 2, 'SKU2-1' => 1 }, inventory.component_quantities)

      fulfillment = Fulfillment::Sku.find(variant.sku)
      assert_equal('bundle', fulfillment.policy)
    end

    def test_summary
      kit = create_product(
        name: 'Test Kit',
        variants: [],
        product_ids: %w(PROD1 PROD2)
      )

      assert_equal(
        {
          variants: 4,
          prices: [15.to_m, 17.to_m, 16.to_m, 18.to_m],
          details: {
            'Color' => %w(Blue White Red),
            'Size' => %w(Small Medium),
            'Material' => %w(Cotton)
          }
        },
        BuildKitVariants.new(kit, params).summary
      )
    end
  end
end
