$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'workarea/package_products/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'workarea-package_products'
  s.version     = Workarea::PackageProducts::VERSION
  s.authors     = ['Adam Clarke']
  s.email       = ['adam@revelry.co']
  s.homepage    = 'https://github.com/workarea-commerce/workarea-package-products'
  s.summary     = 'Add support for package products to the Workarea Commerce Platform'
  s.description = 'Add support for package products to the Workarea Commerce Platform'

  s.files = `git ls-files`.split("\n")

  s.license = 'Business Software License'
  s.test_files = Dir['spec/**/*']

  s.required_ruby_version = '>= 2.3.0'

  s.add_dependency 'workarea', '~> 3.x', '>= 3.5.x'
end
