require 'test_helper'

module Workarea
  module Admin
    class PackageProductViewModelTest < TestCase
      def test_bundled_products
        create_product(id: 'PROD1', name: 'Test Product 1')
        create_product(id: 'PROD2', name: 'Test Product 2')
        create_product(id: 'PROD3', name: 'Test Product 3')

        product = create_product(
          name: 'Test Package',
          template: 'package',
          product_ids: %w(PROD2 PROD3 PROD1)
        )

        view_model = Admin::ProductViewModel.new(product)
        assert_equal(%w(PROD2 PROD3 PROD1), view_model.bundled_products.map(&:id))
      end

      def test_templates
        product = create_product(
          template: 'package',
          product_ids: ['PROD1']
        )

        view_model = Admin::ProductViewModel.new(product)
        assert_equal(%w(package family), view_model.templates.map(&:last))

        product = create_product(template: 'generic')

        view_model = Admin::ProductViewModel.new(product)
        templates = view_model.templates.map(&:last)
        assert_includes(templates, 'generic')
        refute_includes(templates, 'package')
        refute_includes(templates, 'family')
      end
    end
  end
end
