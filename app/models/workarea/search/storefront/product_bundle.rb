module Workarea
  module Search
    class Storefront
      class ProductBundle < Product
        def skus
          bundled_products.flat_map(&:skus)
        end

        def variant_count
          bundled_products.sum(&:variant_count)
        end

        def orders_score
          return 0 unless bundled_products.present?
          bundled_products.sum(&:orders_score) / bundled_products.size
        end

        def variant_details_text
          @variant_details_text ||= bundled_products_variants.map do |variant|
            "#{variant.name} #{HashText.new(variant.details).text}"
          end.join(' ')
        end

        private

        def bundled_products
          return @bundled_products if defined?(@bundled_products)

          products = Catalog::Product.find_ordered(model.product_ids)
          @bundled_products ||= products.map { |p| Product.new(p) }
        end

        def bundled_products_variants
          @package_products_variants ||=
            bundled_products.map(&:model).flat_map { |p| p.variants.select(&:active?) }
        end
      end
    end
  end
end
