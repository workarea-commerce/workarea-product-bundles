require 'test_helper'

module Workarea
  module Storefront
    module ProductTemplates
      class PackageViewModelTest < TestCase
        def test_packaged_products
          product_one = create_product(template: 'option_selects')
          product_two = create_product
          package = create_product(product_ids: [product_one.id, product_two.id])

          view_model = Storefront::ProductTemplates::PackageViewModel.new(package)

          assert_equal(
            Storefront::ProductTemplates::OptionSelectsViewModel,
            view_model.packaged_products.first.class
          )

          assert_equal(
            Storefront::ProductViewModel,
            view_model.packaged_products.second.class
          )

          product_one = create_product(template: 'test')
          product_two = create_product(variants: [])
          package = create_product(product_ids: [product_one.id, product_two.id])

          view_model = Storefront::ProductTemplates::PackageViewModel.new(package)
          assert_equal(1, view_model.packaged_products.length)
        end
      end
    end
  end
end
