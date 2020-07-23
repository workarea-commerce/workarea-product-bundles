require 'test_helper'

module Workarea
  class BundleCreateCatalogProductsIntegrationTest < Workarea::IntegrationTest
    include Admin::IntegrationTest

    def test_index
      get admin.create_catalog_products_path
      assert(response.ok?)

      get admin.create_catalog_products_path(product_type: 'standard')
      assert(response.ok?)

      get admin.create_catalog_products_path(product_type: 'package')
      assert_redirected_to(admin.create_catalog_product_bundles_path(template: 'package'))

      get admin.create_catalog_products_path(product_type: 'family')
      assert_redirected_to(admin.create_catalog_product_bundles_path(template: 'family'))

      get admin.create_catalog_products_path(product_type: 'kit')
      assert_redirected_to(admin.create_catalog_product_kits_path)
    end

    def test_edit
      product = create_product

      get admin.edit_create_catalog_product_path(product)
      assert(response.ok?)

      product.update(product_ids: ['123'], variants: [])

      get admin.edit_create_catalog_product_path(product)
      assert_redirected_to(admin.edit_create_catalog_product_bundle_path(product))

      product.update(variants: [
        { sku: 'SKU1', components: [{ product_id: '123', sku: 'SKU123' }] }
      ])

      get admin.edit_create_catalog_product_path(product)
      assert_redirected_to(admin.edit_create_catalog_product_kit_path(product))
    end
  end
end
