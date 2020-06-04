module Workarea
  module Admin
    class VariantComponentViewModel < ApplicationViewModel
      def product
        @product ||= begin
          product = options[:product].presence
          product ||= Catalog::Product.find(product_id) if product_id
          product ||= Catalog::Product.find_by_sku(sku)

          if product.respond_to?(:bundled_products)
            product
          else
            ProductViewModel.wrap(product, sku: sku)
          end
        end
      end

      def name
        "#{product.name} (#{sku})"
      end
    end
  end
end
