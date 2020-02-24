# Javascript Appends

Workarea.append_javascripts(
  'storefront.modules',
  'workarea/storefront/package_products/modules/bundle_sku_selects',
  'workarea/storefront/package_products/modules/bundle_option_buttons'
)

# CSS Appends

Workarea.append_stylesheets(
  'storefront.components',
  'workarea/storefront/package_products/components/product_details_bundled_products',
  'workarea/storefront/package_products/components/bundled_product_details'
)

Workarea.append_stylesheets(
  'admin.components',
  'workarea/admin/package_products/components/product_cards'
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
  'admin.variant_sections',
  'workarea/admin/catalog_variants/components'
)

Workarea.append_partials(
  'admin.product_fields',
  'workarea/admin/catalog_products/show_bundled_products_field'
)
