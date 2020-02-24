require 'test_helper'

module Workarea
  module Storefront
    class PackageProductViewModelTest < TestCase
      def test_bundled_products
        package_child_1 = create_product(variants: [{ sku: 'SKUC1', regular: 5.00 }])
        package_child_2 = create_product
        package_product = create_product(product_ids: [package_child_1.id, package_child_2.id])

        view_model = ProductViewModel.new(package_product)
        assert_equal(package_child_1.id, view_model.bundled_products[0].id)
        assert_equal(package_child_2.id, view_model.bundled_products[1].id)

        create_inventory(id: 'SKUC1', policy: 'standard', available: 0)

        view_model = ProductViewModel.new(package_product)
        assert_equal(package_child_2.id, view_model.bundled_products[0].id)
        assert_equal(1, view_model.bundled_products.count)

        bad_packaged_product = create_product(product_ids: [package_child_2.id, 'not_an_id'])
        view_model = ProductViewModel.new(bad_packaged_product)
        assert_equal(1, view_model.bundled_products.count)
      end
    end
  end
end
