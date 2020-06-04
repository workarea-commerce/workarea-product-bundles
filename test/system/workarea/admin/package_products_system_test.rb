require 'test_helper'

module Workarea
  module Admin
    class ProductBundlesSystemTest < Workarea::SystemTest
      include Admin::IntegrationTest

      def test_adding_bundled_products
        create_product(name: 'Foo')
        create_product(name: 'Bar')
        create_product(id: 'BAZ', name: 'Baz')
        product = create_product(template: 'package', product_ids: %w(BAZ))
        visit admin.catalog_product_path(product)

        click_link t('workarea.admin.catalog_products.cards.bundled_products.title')
        assert(page.has_content?('Foo'))
        assert(page.has_content?('Bar'))

        click_link 'Foo'
        assert(page.has_content?('Success'))
        assert(page.has_selector?('.product-summary__remove'))
        click_link t('workarea.admin.featured_products.select.sort_link')

        assert(page.has_content?('Foo'))
        assert(page.has_no_content?('Bar'))
        click_link t('workarea.admin.featured_products.edit.browse_link')

        assert(page.has_selector?('.product-summary__remove'))
        click_link 'Foo'
        assert(page.has_content?('Success'))
        click_link t('workarea.admin.featured_products.select.sort_link')

        assert(page.has_no_content?('Foo'))
        assert(page.has_no_content?('Bar'))
      end

      def test_creating_a_package_product
        create_category(name: 'Test Category')
        create_product(name: 'Foo')
        create_product(name: 'Bar')

        visit admin.catalog_products_path

        click_link 'Add New Product'

        choose 'product_type_bundle'
        click_button 'select_product_type'

        fill_in 'product[name]', with: 'Test Package'
        click_button 'save_setup'

        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.admin.create_catalog_product_bundles.bundled_products.title', product_name: 'Test Package')))

        click_link('Foo')
        assert(page.has_content?('Success'))
        click_link('Bar')
        assert(page.has_content?('Success'))

        click_link(t('workarea.admin.create_catalog_product_bundles.bundled_products.continue_to_images'))
        assert(page.has_content?(t('workarea.admin.create_catalog_products.images.add_images', product_name: 'Test Package')))

        attach_file 'images[][image]', product_image_file_path
        click_button 'save_images'

        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.admin.create_catalog_products.details.add_details', product_name: 'Test Package')))
        click_button 'save_details'

        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.admin.create_catalog_products.content.add_content', product_name: 'Test Package')))

        page.execute_script(<<-js
          $("body", $("iframe.wysihtml-sandbox").contents())
            .text("Description")
          js
                           )

        click_button 'save_content'

        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.admin.create_catalog_products.categorization.categorize', product_name: 'Test Package')))

        find('.select2-selection--multiple').click
        assert(page.has_content?('Test Category'))
        find('.select2-results__option', text: 'Test Category').click

        click_button 'add_categories'
        assert(page.has_content?('Success'))
        assert(page.has_content?('Test Category'))
        click_link t('workarea.admin.create_catalog_products.categorization.continue_to_publish')

        assert(page.has_content?(t('workarea.admin.create_catalog_products.publish.when_does_it_go_live', product_name: 'Test Package')))
        click_button 'publish'

        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.admin.catalog_products.cards.bundled_products.title')))
      end
    end
  end
end
