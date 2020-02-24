require 'test_helper'

module Workarea
  module Admin
    class CreateCatalogProductBundlesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_create
        post admin.create_catalog_product_bundles_path,
             params: {
               product: {
                 name: 'Test Product',
                 slug: 'foo-bar',
                 tag_list: 'foo,bar,baz',
                 template: 'package'
               }
             }

        assert_equal(1, Catalog::Product.count)
        product = Catalog::Product.first

        assert_equal('Test Product', product.name)
        assert_equal('foo-bar', product.slug)
        assert_equal(%w(foo bar baz), product.tags)
        assert_equal('package', product.template)
        refute(product.active?)
      end

      def test_save_images
        product = create_product

        post admin.save_images_create_catalog_product_bundle_path(product),
             params: {
               images: [{ image: product_image_file_path, option: 'blue' }]
             }

        product.reload

        assert_equal(1, product.images.length)
        assert(product.images.first.image.present?)
        assert_equal('blue', product.images.first.option)

        post admin.save_images_create_catalog_product_bundle_path(product),
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

        post admin.save_details_create_catalog_product_bundle_path(product),
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

        post admin.save_content_create_catalog_product_bundle_path(product),
             params: { product: { description: 'foo' } }

        product.reload
        assert_equal('foo', product.description)
      end

      def test_save_categorization
        product = create_product
        category = create_category(product_ids: [])

        post admin.save_categorization_create_catalog_product_bundle_path(product),
             params: { category_ids: [category.id] }

        category.reload
        assert_equal([product.id], category.product_ids)
      end

      def test_publish
        product = create_product
        create_release(name: 'Foo Release', publish_at: 1.week.from_now)
        get admin.publish_create_catalog_product_bundle_path(product)

        assert(response.ok?)
        assert_includes(response.body, 'Foo Release')
      end

      def test_save_publish
        product = create_product(active: false)

        post admin.save_publish_create_catalog_product_bundle_path(product),
             params: { activate: 'now' }

        assert(product.reload.active?)

        product.update_attributes!(active: false)

        post admin.save_publish_create_catalog_product_bundle_path(product),
             params: { activate: 'new_release', release: { name: '' } }

        assert(Release.empty?)
        assert(response.ok?)
        refute(response.redirect?)
        refute(product.reload.active?)

        post admin.save_publish_create_catalog_product_bundle_path(product),
             params: { activate: 'new_release', release: { name: 'Foo' } }

        refute(product.reload.active?)
        assert_equal(1, Release.count)
        release = Release.first
        assert_equal('Foo', release.name)
        release.as_current { assert(product.reload.active?) }

        release = create_release
        product.update_attributes!(active: false)

        post admin.save_publish_create_catalog_product_bundle_path(product),
             params: { activate: release.id }

        refute(product.reload.active?)
        release.as_current { assert(product.reload.active?) }
      end
    end
  end
end
