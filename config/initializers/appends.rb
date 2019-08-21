# Javascript Appends
Workarea.append_javascripts(
  'storefront.modules',
  'workarea/storefront/package_products/modules/family_product_add_to_cart'
)

Workarea.append_javascripts(
  'storefront.templates',
  'workarea/storefront/package_products/templates/family_add_to_cart_checkbox'
)

Workarea.append_stylesheets(
  'admin.components',
  'workarea/admin/package_products/components/product_cards'
)

Workarea.append_stylesheets(
  'storefront.components',
  'workarea/storefront/package_products/components/product_detail_packaged_products'
)

# Partial Appends
Workarea.append_partials(
  'admin.catalog_product_cards',
  'workarea/admin/catalog_products/packaged_products_card'
)

Workarea.append_partials(
  'admin.product_index_actions',
  'workarea/admin/catalog_products/create_package_button'
)
