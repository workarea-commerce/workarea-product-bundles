module Workarea
  module Storefront
    module ProductBundlesHelper
      def bundle_field_prefix(product, field)
        return field if !product.bundle? || product.package?
        "bundled_items[][#{field}]"
      end

      def bundle_name_prefix(product, field)
        return field if !product.bundle? || product.package?
        "bundled_items__#{field}"
      end
    end
  end
end
