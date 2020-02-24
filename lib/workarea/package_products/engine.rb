module Workarea
  module PackageProducts
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::PackageProducts

      config.to_prepare do
        Workarea::Storefront::ApplicationController.helper(
          Workarea::Storefront::ProductBundlesHelper
        )
      end
    end
  end
end
