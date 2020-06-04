require 'test_helper'

module Workarea
  module Admin
    class VariantComponentViewModelTest < TestCase
      setup :product

      def product
        @product ||= create_product(
          id: 'PROD1',
          name: 'Test Product',
          variants: [{ sku: 'SKU1' }]
        )
      end

      def test_product
        component = Catalog::VariantComponent.new(sku: 'SKU1')

        view_model = VariantComponentViewModel.wrap(component)
        assert_equal(product, product)

        component.product_id = product.id
        view_model = VariantComponentViewModel.wrap(component)
        assert_equal(product, product)

        view_model = VariantComponentViewModel.wrap(component, product: product)
        assert_equal(product, product)
      end

      def test_name
        component = Catalog::VariantComponent.new(sku: 'SKU1')
        view_model = VariantComponentViewModel.wrap(component)


        assert_equal('Test Product (SKU1)', view_model.name)
      end
    end
  end
end
