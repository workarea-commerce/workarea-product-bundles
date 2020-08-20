module Workarea
  module Admin
    module ProductBundlesHelper
      # We only want to check activeness on discrete bundles since
      # they have no inventory. This will return nothing if the product
      # is an active, discrete bundle.
      def summary_inventory_status_css_classes(product)
        return super if !product.discrete_bundle? || !product.active?
        []
      end
    end
  end
end
