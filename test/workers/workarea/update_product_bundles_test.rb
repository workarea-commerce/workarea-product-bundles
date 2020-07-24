require 'test_helper'

module Workarea
  class UpdateProductBundlesTest < Workarea::TestCase
    include TestCase::SearchIndexing

    def test_perform
      product = create_product(id: 'PROD1')
      bundle = create_product(
        id: 'KIT',
        variants: [
          {
            sku: 'KSKU',
            components: [
              { product_id: 'PROD1', sku: 'SKU1' },
              { product_id: 'PROD2', sku: 'SKU2' },
              { product_id: 'PROD3', sku: 'SKU3' },
            ]
          }
        ],
        product_ids: [
          product.id,
          create_product(id: 'PROD2').id,
          create_product(id: 'PROD3').id
        ]
      )

      product.destroy
      UpdateProductBundles.new.perform(product.id)
      bundle.reload

      refute_includes(bundle.product_ids, product.id)
      refute_includes(bundle.variants.first.components.map(&:product_id), product.id)
    end
  end
end
