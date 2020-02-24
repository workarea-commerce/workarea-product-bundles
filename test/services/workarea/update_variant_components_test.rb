require 'test_helper'

module Workarea
  class UpdateVariantComponentsTest < TestCase
    def test_perform
      product = create_product(
        variants: [
          {
            sku: 'SKU1',
            components: [
              { product_id: 'CPROD1', sku: 'CSKU1' },
              { product_id: 'CPROD2', sku: 'CSKU2' }
            ]
          }
        ]
      )

      variant = product.variants.first
      params = [
        { id: variant.components.first.id.to_s, remove: 'true' },
        { id: variant.components.last.id.to_s, quantity: 2 },
        { product_id: 'CPROD3', sku: 'CSKU3' }
      ]

      UpdateVariantComponents.new(variant, params).perform

      assert_equal(2, variant.components.size)

      component = variant.components.detect { |c| c.product_id == 'CPROD2' }
      assert_equal(2, component.quantity)

      component = variant.components.detect { |c| c.product_id == 'CPROD3' }
      assert_equal('CSKU3', component.sku)
    end
  end
end
