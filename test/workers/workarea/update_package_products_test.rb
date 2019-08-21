require 'test_helper'

module Workarea
  class UpdatePackageProductsTest < Workarea::TestCase
    include TestCase::SearchIndexing

    def test_perform
      product = create_product(id: 'PROD1')
      package = create_product(
        id: 'PACK',
        template: 'package',
        variants: [],
        product_ids: [
          product.id,
          create_product(id: 'PROD2').id,
          create_product(id: 'PROD3').id
        ]
      )

      product.destroy
      UpdatePackageProducts.new.perform(product.id)
      package.reload

      refute_includes(package.product_ids, product.id)
    end
  end
end
