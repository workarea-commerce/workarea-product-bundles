module Workarea
  module ProductBundles
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::ProductBundles

      config.to_prepare do
        Workarea::Storefront::ApplicationController.helper(
          Workarea::Storefront::ProductBundlesHelper
        )
        Workarea::Admin::ApplicationController.helper(
          Workarea::Admin::ProductBundlesHelper
        )
      end
    end
  end
end
