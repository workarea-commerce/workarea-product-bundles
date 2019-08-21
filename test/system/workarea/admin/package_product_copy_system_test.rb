require 'test_helper'

module Workarea
  module Admin
    class PackageProductCopySystemTest < Workarea::SystemTest
      include Admin::IntegrationTest

      def test_copy_package_product
        product = create_product(template: 'package')

        visit admin.catalog_product_path(product)
        click_link t('workarea.admin.catalog_products.show.copy_product')

        fill_in 'product[id]', with: 'FOOBAR'

        click_button 'create_copy'
        assert(page.has_content?('Success'))
        assert_current_path(
          admin.edit_create_catalog_package_product_path(
            "#{product.slug}-1",
            continue: true
          )
        )
      end
    end
  end
end
