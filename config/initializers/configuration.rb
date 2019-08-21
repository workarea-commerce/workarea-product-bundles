Workarea.configure do |config|
  config.product_templates += %i(package family)
  config.package_product_templates = %i(package family)
  config.product_quickview_templates ||= []
  config.product_quickview_templates -= config.package_product_templates
end
