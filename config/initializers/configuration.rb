Workarea.configure do |config|
  config.seeds.insert_after('Workarea::ProductsSeeds', 'Workarea::ProductBundleSeeds')
  config.seeds.insert_after('Workarea::ProductsSeeds', 'Workarea::ProductKitSeeds')

  config.product_templates += %i(package family)
  config.product_bundle_templates = %i(package family)
  config.product_quickview_templates ||= []
  config.product_quickview_templates -= config.product_bundle_templates

  config.inventory_policies << 'Workarea::Inventory::Policies::DeferToComponents'
  config.fulfillment_policies << 'Workarea::Fulfillment::Policies::Bundle'
  config.pricing_calculators.insert_after(
    'Workarea::Pricing::Calculators::CustomizationsCalculator',
    'Workarea::Pricing::Calculators::BundledItemCalculator'
  )
end
