require 'test_helper'

module Workarea
  class CatalogVariantComponentsIntegrationTest < Workarea::IntegrationTest
    include Admin::IntegrationTest

    def test_update
      product = create_product(
        variants: [{
          name: 'Test',
          sku: 'SKU1234',
          details: { 'Color' => 'Red' },
          components: [
            { product_id: 'CPROD1', sku: 'CSKU1' },
            { product_id: 'CPROD2', sku: 'CSKU2' }
          ]
        }]
      )

      variant = product.variants.first

      patch admin.catalog_product_variant_path(product, variant),
        params: {
          variant: { name: 'New Name', sku: 'SKU5678' },
          details: %w(Color Blue),
          new_details: %w(Size Large),
          components: [
            { id: variant.components.first.id.to_s, remove: 'true' },
            { id: variant.components.last.id.to_s, quantity: 2 },
            { id: nil, product_id: 'CPROD3', sku: 'CSKU3' }
          ]
        }

      product.reload
      assert_equal(product.variants.length, 1)

      variant = product.variants.first
      assert_equal('SKU5678', variant.sku)
      assert_equal('New Name', variant.name)
      assert_equal(['Blue'], variant.details['Color'])
      assert_equal(['Large'], variant.details['Size'])

      assert_equal(2, variant.components.size)

      component = variant.components.detect { |c| c.product_id == 'CPROD2' }
      assert_equal(2, component.quantity)

      component = variant.components.detect { |c| c.product_id == 'CPROD3' }
      assert_equal('CSKU3', component.sku)
    end
  end
end
