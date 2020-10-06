require 'test_helper'

module Workarea
  module Admin
    class ProductKitsSystemTest < Workarea::SystemTest
      include Admin::IntegrationTest

      setup :component_data

      def component_data
        @product_1 = create_product(
          id: 'PROD1',
          name: 'Foo',
          variants: [
            {
              sku: 'SKU1-1',
              regular: 5.to_m,
              details: { 'Color' => %w(Blue), 'Size' => %w(Small) }
            },
            {
              sku: 'SKU1-2',
              regular: 6.to_m,
              details: { 'Color' => %w(Blue), 'Size' => %w(Medium) }
            }
          ]
        )

        @product_2 = create_product(
          id: 'PROD2',
          name: 'Bar',
          variants: [
            {
              sku: 'SKU2-1',
              regular: 10.to_m,
              details: { 'Color' => %w(White), 'Material' => %w(Cotton) }
            },
            {
              sku: 'SKU2-2',
              regular: 12.to_m,
              details: { 'Color' => %w(Red), 'Material' => %w(Cotton) }
            }
          ]
        )
      end

      def test_variant_creation
        product = create_product(
          id: 'KP001',
          name: 'Test Kit',
          product_ids: %w(PROD1 PROD2),
          variants: []
        )

        visit admin.variants_create_catalog_product_kit_path(product)

        table = page.find('[id^=bundled-product-prod1]')

        within table do
          assert(page.has_content?(@product_1.name))
          assert(page.has_content?('Color'))
          assert(page.has_content?('Blue'))
          assert(page.has_content?('Size'))
          assert(page.has_content?('Small'))
          assert(page.has_content?('Medium'))

          assert(page.has_content?(t('workarea.admin.filterable.showing', count: 3)))
          fill_in 'filter_options', with: 'Small'
          assert(page.has_content?(t('workarea.admin.filterable.showing', count: 1)))

          assert(page.has_content?('Small'))
          assert(page.has_no_content?('Medium'))
          assert(page.has_no_content?('Blue'))

          assert(page.has_content?(t('workarea.admin.kit_variant_options.selected', count: 0)))
          check 'select_all_size'
          assert(page.has_content?(t('workarea.admin.kit_variant_options.selected', count: 1)))

          fill_in 'filter_options', with: ''
          assert(page.has_content?(t('workarea.admin.filterable.showing', count: 3)))

          assert(find('[id$=size_small_checkbox]').checked?)
          refute(find('[id$=size_medium_checkbox]').checked?)
          refute(find('[id$=color_blue_checkbox]').checked?)

          uncheck 'select_all_size'

          refute(find('[id$=size_small_checkbox]').checked?)
          refute(find('[id$=size_medium_checkbox]').checked?)
          refute(find('[id$=color_blue_checkbox]').checked?)

          check 'select_all_size'

          assert(find('[id$=size_small_checkbox]').checked?)
          assert(find('[id$=size_medium_checkbox]').checked?)
          refute(find('[id$=color_blue_checkbox]').checked?)

          find('[id$=details_size_copy_true_label]').click
          find('[id$=details_color_copy_true_label]').click

          click_link t('workarea.admin.create_catalog_product_kits.variants.create.copy_product')
        end

        assert(page.has_content?(@product_1.name, count: 2))

        table = page.find('[id^=bundled-product-prod2]')

        within table do
          check 'select_all_color'
          find('[id$=details_color_copy_true_label]').click
          find('[id$=details_color_rename]').set 'Secondary Color'
          find('[id$=details_material_copy_true_label]').click
        end

        within '#creation-preview' do
          assert(page.has_content?('4'))
          assert(page.has_content?(t('workarea.admin.kit_variant_options.preview.variants.other')))
          assert(page.has_content?('Blue'))
          assert(page.has_content?('Color'))
          assert(page.has_content?('White and Red'))
          assert(page.has_content?('Secondary Color'))
          assert(page.has_content?('Small and Medium'))
          assert(page.has_content?('Size'))
          assert(
            page.has_content?(
              t(
                'workarea.admin.kit_variant_options.preview.price_range',
                min: '$15.00',
                max: '$18.00'
              )
            )
          )
        end

        fill_in 'variant[sku]', with: 'KP'
        click_button t('workarea.admin.create_catalog_product_kits.variants.create.button')

        assert_current_path(admin.manage_variants_create_catalog_product_kit_path(product))

        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.admin.filterable.showing', count: 4)))

        product.reload
        product.skus.each { |sku| assert(page.has_content?(sku)) }

        fill_in 'filter_skus', with: 'SKU1-1'
        assert(page.has_content?(t('workarea.admin.filterable.showing', count: 2)))

        assert(page.has_no_content?('SKU1-2'))

        fill_in 'filter_skus', with: ''
        assert(page.has_content?(t('workarea.admin.filterable.showing', count: 4)))

        within find("#variant-#{product.variants.first.sku}") do
          click_link t('workarea.admin.actions.delete')
        end

        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.admin.filterable.showing', count: 3)))

        product.reload
        variant = product.variants.first
        click_link variant.sku

        assert_current_path(admin.edit_variant_create_catalog_product_kit_path(product, variant.sku))

        fill_in 'variant[sku]', with: 'EDITEDSKU'
        fill_in 'pricing[tax_code]', with: '001'

        select @product_1.name, from: 'components[][product_id]'
        select 'SKU1-2', from: 'components[][sku]'

        select @product_2.name, from: 'components[][product_id]'
        select 'SKU2-1', from: 'components[][sku]'

        click_button t('workarea.admin.create_catalog_product_kits.variants.manage.update')

        assert(page.has_content?('Success'))
        assert(page.has_content?('EDITEDSKU'))

        click_link t('workarea.admin.create_catalog_product_bundles.bundled_products.continue_to_images')
      end

      def test_variant_creation_with_no_option_variants
        @product_1.variants.each { |v| v.details = {} }
        @product_1.save!

        product = create_product(
          id: 'KP001',
          name: 'Test Kit',
          product_ids: %w(PROD1 PROD2),
          variants: []
        )

        visit admin.variants_create_catalog_product_kit_path(product)

        table = page.find('[id^=bundled-product-prod1]')

        within table do
          assert(page.has_content?(@product_1.name))
          assert(page.has_content?('SKU1-1'))
          assert(page.has_content?('SKU1-2'))

          find('[id$=sku1_1_sku_checkbox]').check

          assert(page.has_content?(t('workarea.admin.kit_variant_options.selected', count: 1)))
        end

        table = page.find('[id^=bundled-product-prod2]')

        within table do
          check 'select_all_color'
          find('[id$=details_color_copy_true_label]').click
          find('[id$=details_material_copy_true_label]').click
        end

        within '#creation-preview' do
          assert(page.has_content?('2'))
          assert(page.has_content?(t('workarea.admin.kit_variant_options.preview.variants.other')))
          assert(page.has_content?('White and Red'))
          assert(page.has_content?('Color'))
          assert(page.has_content?('Cotton'))
          assert(page.has_content?('Material'))
          assert(
            page.has_content?(
              t(
                'workarea.admin.kit_variant_options.preview.price_range',
                min: '$15.00',
                max: '$17.00'
              )
            )
          )
        end

        click_button t('workarea.admin.create_catalog_product_kits.variants.create.button')

        assert_current_path(admin.manage_variants_create_catalog_product_kit_path(product))

        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.admin.filterable.showing', count: 2)))
      end

      def test_full_kit_workflow
        create_category(name: 'Test Category')

        visit admin.catalog_products_path

        click_link 'Add New Product'

        choose 'product_type_kit'
        click_button 'select_product_type'

        fill_in 'product[name]', with: 'Test Kit'
        click_button 'save_setup'

        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.admin.create_catalog_product_kits.bundled_products.title', product_name: 'Test Kit')))

        click_link('Foo')
        assert(page.has_content?('Success'))
        click_link('Bar')
        assert(page.has_content?('Success'))

        click_link(t('workarea.admin.create_catalog_product_kits.bundled_products.continue_to_variants'))

        within page.find('[id^=bundled-product-prod1]') do
          check 'select_all_color'
          find('[id$=details_color_copy_true_label]').click
          find('[id$=details_size_copy_true_label]').click
        end
        within page.find('[id^=bundled-product-prod2]') do
          check 'select_all_color'
          find('[id$=details_color_copy_true_label]').click
          find('[id$=details_material_copy_true_label]').click
        end

        click_button t('workarea.admin.create_catalog_product_kits.variants.create.button')
        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.admin.filterable.showing', count: 4)))

        click_link(t('workarea.admin.create_catalog_product_bundles.bundled_products.continue_to_images'))
        assert(page.has_content?(t('workarea.admin.create_catalog_products.images.add_images', product_name: 'Test Kit')))

        attach_file 'images[][image]', product_image_file_path
        click_button 'save_images'

        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.admin.create_catalog_products.details.add_details', product_name: 'Test Kit')))
        click_button 'save_details'

        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.admin.create_catalog_products.content.add_content', product_name: 'Test Kit')))

        page.execute_script(<<-js
          $("body", $("iframe.wysihtml-sandbox").contents())
            .text("Description")
          js
        )

        click_button 'save_content'

        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.admin.create_catalog_products.categorization.categorize', product_name: 'Test Kit')))

        find('.select2-selection--multiple').click
        assert(page.has_content?('Test Category'))
        find('.select2-results__option', text: 'Test Category').click

        click_button 'add_categories'
        assert(page.has_content?('Success'))
        assert(page.has_content?('Test Category'))
        click_link t('workarea.admin.create_catalog_products.categorization.continue_to_publish')

        assert(page.has_content?(t('workarea.admin.create_catalog_products.publish.when_does_it_go_live', product_name: 'Test Kit')))
        click_button 'publish'

        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.admin.catalog_products.cards.bundled_products.title')))
      end
    end
  end
end
