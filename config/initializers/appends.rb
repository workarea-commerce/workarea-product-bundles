# Javascript Appends

Workarea.append_javascripts(
  'admin.modules',
  'workarea/admin/product_bundles/modules/variant_components',
  'workarea/admin/product_bundles/modules/variant_component_selects',
  'workarea/admin/product_bundles/modules/remote_content',
  'workarea/admin/product_bundles/modules/filterable'
)

Workarea.append_javascripts(
  'storefront.modules',
  'workarea/storefront/product_bundles/modules/bundle_sku_selects',
  'workarea/storefront/product_bundles/modules/bundle_option_buttons'
)

# CSS Appends

Workarea.append_stylesheets(
  'storefront.components',
  'workarea/storefront/product_bundles/components/product_details_bundled_products',
  'workarea/storefront/product_bundles/components/bundled_product_details'
)

Workarea.append_stylesheets(
  'admin.components',
  'workarea/admin/product_bundles/components/product_cards',
  'workarea/admin/product_bundles/components/component_sku_table',
  'workarea/admin/product_bundles/components/component_sku_select'
)

# Partial Appends

Workarea.append_partials(
  'storefront.add_to_cart_form',
  'workarea/storefront/products/bundled_products'
)

Workarea.append_partials(
  'storefront.cart_item_details',
  'workarea/storefront/carts/bundled_items'
)

Workarea.append_partials(
  'admin.catalog_product_cards',
  'workarea/admin/catalog_products/bundled_products_card'
)

Workarea.append_partials(
  'admin.product_index_actions',
  'workarea/admin/catalog_products/create_package_button'
)

Workarea.append_partials(
  'admin.additional_variant_information_fields',
  'workarea/admin/catalog_variants/components'
)

Workarea.append_partials(
  'admin.product_fields',
  'workarea/admin/catalog_products/show_bundled_products_field'
)

Workarea.append_partials(
  'admin.inventory_sku_policy_info',
  'workarea/admin/inventory_skus/defer_to_components_info'
)

Workarea.append_partials(
  'admin.fulfillment_sku_policy_info',
  'workarea/admin/fulfillment_skus/bundle_info'
)
