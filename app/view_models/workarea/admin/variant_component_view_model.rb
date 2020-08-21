module Workarea
  module Admin
    class VariantComponentViewModel < ApplicationViewModel
      delegate :details, to: :product_variant

      def product
        @product ||= begin
          product = options[:product].presence
          product ||= Catalog::Product.find(product_id) if product_id
          product ||= Catalog::Product.find_by_sku(sku)

          if product.is_a?(ProductViewModel)
            product
          else
            ProductViewModel.wrap(product, sku: sku)
          end
        end
      end

      def name
        "#{product.name} (#{sku})"
      end

      def product_variant
        @product_variant ||= product.variants.detect { |v| v.sku == sku }
      end
    end
  end
end
