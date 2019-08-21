module Workarea
  module Search
    class Storefront
      class PackageProduct < Product
        def skus
          packaged_products.flat_map(&:skus)
        end

        def variant_count
          packaged_products.sum(&:variant_count)
        end

        def orders_score
          return 0 unless packaged_products.present?
          packaged_products.sum(&:orders_score) / packaged_products.size
        end

        def variant_details_text
          @variant_details_text ||= packaged_products_variants.map do |variant|
            "#{variant.name} #{HashText.new(variant.details).text}"
          end.join(' ')
        end

        private

        def packaged_products
          return @packaged_products if defined?(@packaged_products)

          products = Catalog::Product.find_ordered(model.product_ids)
          @packaged_products ||= products.map { |p| Product.new(p) }
        end

        def packaged_products_variants
          @package_products_variants ||=
            packaged_products.map(&:model).flat_map { |p| p.variants.active }
        end
      end
    end
  end
end
