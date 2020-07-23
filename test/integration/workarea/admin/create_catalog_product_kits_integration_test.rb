require 'test_helper'

module Workarea
  module Admin
    class CreateCatalogProductKitsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def setup_component_data
        create_product(
          id: 'PROD1',
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

        create_product(
          id: 'PROD2',
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

      def test_create
        post admin.create_catalog_product_kits_path,
             params: {
               product: {
                 name: 'Test Product',
                 slug: 'foo-bar',
                 tag_list: 'foo,bar,baz',
                 template: 'option_selects'
               }
             }

        assert_equal(1, Catalog::Product.count)
        product = Catalog::Product.first

        assert_equal('Test Product', product.name)
        assert_equal('foo-bar', product.slug)
        assert_equal(%w(foo bar baz), product.tags)
        assert_equal('option_selects', product.template)
        refute(product.active?)
      end

      def test_save_variants
        setup_component_data

        product = create_product(
          name: 'Test Kit',
          variants: [],
          product_ids: %w(PROD1 PROD2)
        )

        post admin.save_variants_create_catalog_product_kit_path(product),
             params: {
               components: {
                 '1' => [
                   { selected: 'true', product_id: 'PROD1', sku: 'SKU1-1', quantity: '2' },
                   { selected: 'true', product_id: 'PROD1', sku: 'SKU1-2', quantity: '2' }
                 ],
                 '2' => [
                   { selected: 'true', product_id: 'PROD2', sku: 'SKU2-1', quantity: '1' },
                   { selected: 'true', product_id: 'PROD2', sku: 'SKU2-2', quantity: '1' }
                 ],
               },
               variant: {
                 sku: 'KP',
                 copy_options: 'true',
                 calculate_pricing: 'true',
               }
             }

        assert_redirected_to(
          admin.manage_variants_create_catalog_product_kit_path(product)
        )

        product.reload
        assert_equal(4, product.variants.count)
      end

      def test_update_variant
        setup_component_data

        product = create_product(
          name: 'Test Kit',
          product_ids: %w(PROD1 PROD2),
          variants: [
            {
              sku: 'SKU1',
              details: { 'Color' => %w(red), 'Size' => %(large) },
              components: [
                { product_id: 'PROD1', sku: 'SKU1-1', quantity: 1 },
                { product_id: 'PROD2', sku: 'SKU2-1', quantity: 2 },
              ],
              regular: 15.to_m
            }
          ]
        )
        variant = product.variants.first

        patch admin.update_variant_create_catalog_product_kit_path(product, variant.sku),
             params: {
               original_sku: 'SKU1',
               variant: { sku: 'SKU1' },
               new_details: ['Season', 'summer', '', ''],
               details: ['Color', 'Red', 'Size', 'medium'],
               details_to_remove: ['Color'],
               components: [
                 { id: variant.components.first.id.to_s, quantity: 1 },
                 { id: variant.components.second.id.to_s, quantity: 3 },
               ],
               pricing: { regular: 12.to_m, tax_code: '001' }
             }


        assert_redirected_to(
          admin.manage_variants_create_catalog_product_kit_path(product)
        )

        variant.reload
        assert_equal(
          { 'Size' => %w(medium), 'Season' => %w(summer) },
          variant.details
        )
        assert_equal(
          { 'SKU1-1' => 1, 'SKU2-1' => 3 },
          variant.component_quantities
        )

        pricing = Pricing::Sku.find(variant.sku)
        assert_equal(12.to_m, pricing.sell_price)
        assert_equal('001', pricing.tax_code)
      end

      def test_destroy_variant
        setup_component_data

        product = create_product(
          name: 'Test Kit',
          product_ids: %w(PROD1 PROD2),
          variants: [
            {
              sku: 'SKU1',
              details: { 'Color' => %w(red), 'Size' => %(large) },
              components: [
                { product_id: 'PROD1', sku: 'SKU1-1', quantity: 1 },
                { product_id: 'PROD2', sku: 'SKU2-1', quantity: 2 },
              ],
              regular: 15.to_m
            }
          ]
        )
        variant = product.variants.first

        delete admin.destroy_variant_create_catalog_product_kit_path(product, variant.sku)

        assert_redirected_to(
          admin.manage_variants_create_catalog_product_kit_path(product)
        )

        product.reload
        assert_equal(0, product.variants.size)
      end

      def test_save_images
        product = create_product

        post admin.save_images_create_catalog_product_kit_path(product),
             params: {
               images: [{ image: product_image_file_path, option: 'blue' }]
             }

        product.reload

        assert_equal(1, product.images.length)
        assert(product.images.first.image.present?)
        assert_equal('blue', product.images.first.option)

        post admin.save_images_create_catalog_product_kit_path(product),
             params: {
               updates: {
                 product.images.first.id => { option: 'green' }
               }
             }

        product.reload

        assert_equal(1, product.images.length)
        assert(product.images.first.image.present?)
        assert_equal('green', product.images.first.option)
      end

      def test_save_details
        product = create_product(filters: {}, details: {})

        post admin.save_details_create_catalog_product_kit_path(product),
             params: {
               filters: %w(Color Red),
               details: %w(Material Cotton)
             }

        product.reload
        assert_equal(['Red'], product.filters['Color'])
        assert_equal(['Cotton'], product.details['Material'])
      end

      def test_save_content
        product = create_product(description: '')

        post admin.save_content_create_catalog_product_kit_path(product),
             params: { product: { description: 'foo' } }

        product.reload
        assert_equal('foo', product.description)
      end

      def test_save_categorization
        product = create_product
        category = create_category(product_ids: [])

        post admin.save_categorization_create_catalog_product_kit_path(product),
             params: { category_ids: [category.id] }

        category.reload
        assert_equal([product.id], category.product_ids)
      end

      def test_publish
        product = create_product
        create_release(name: 'Foo Release', publish_at: 1.week.from_now)
        get admin.publish_create_catalog_product_kit_path(product)

        assert(response.ok?)
        assert_includes(response.body, 'Foo Release')
      end

      def test_save_publish
        product = create_product(active: false)

        post admin.save_publish_create_catalog_product_kit_path(product),
             params: { activate: 'now' }

        assert(product.reload.active?)

        product.update_attributes!(active: false)

        post admin.save_publish_create_catalog_product_kit_path(product),
             params: { activate: 'new_release', release: { name: '' } }

        assert(Release.empty?)
        assert(response.ok?)
        refute(response.redirect?)
        refute(product.reload.active?)

        post admin.save_publish_create_catalog_product_kit_path(product),
             params: { activate: 'new_release', release: { name: 'Foo' } }

        refute(product.reload.active?)
        assert_equal(1, Release.count)
        release = Release.first
        assert_equal('Foo', release.name)
        release.as_current { assert(product.reload.active?) }

        release = create_release
        product.update_attributes!(active: false)

        post admin.save_publish_create_catalog_product_kit_path(product),
             params: { activate: release.id }

        refute(product.reload.active?)
        release.as_current { assert(product.reload.active?) }
      end
    end
  end
end
