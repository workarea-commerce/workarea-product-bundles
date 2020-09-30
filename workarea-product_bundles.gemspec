$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'workarea/product_bundles/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'workarea-product_bundles'
  s.version     = Workarea::ProductBundles::VERSION
  s.authors     = ['Matt Duffy']
  s.email       = ['mduffy@workarea.com']
  s.homepage    = 'https://github.com/workarea-commerce/workarea-product-bundles'
  s.summary     = 'Add support for package products to the Workarea Commerce Platform'
  s.description = 'Add support for package products to the Workarea Commerce Platform'

  s.files = `git ls-files`.split("\n")

  s.license = 'Business Software License'
  s.test_files = Dir['spec/**/*']

  s.required_ruby_version = '>= 2.3.0'

  s.add_dependency 'workarea', '~> 3.x', '>= 3.5.20'
end
