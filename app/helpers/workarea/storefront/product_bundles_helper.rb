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

      def show_bundled_product_add_to_cart?(product)
        product.package?
      end

      def bundle_fixed_selection?(product)
        product.kit?
      end
    end
  end
end
