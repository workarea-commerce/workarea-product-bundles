module Workarea
  class BuildKitVariants
    class Params
      attr_reader :raw, :bundled_products
      delegate_missing_to :raw

      def initialize(params)
        @raw = params
      end

      def bundled_products
        raw[:bundled_products]
      end

      def variant
        raw[:variant].presence || {}
      end

      def new_details?
        variant[:new_details].to_s =~ /true/i
      end

      def calculate_pricing?
        variant[:calculate_pricing].to_s =~ /true/i
      end

      def custom_price
        variant[:price]
      end

      def new_details
        raw[:new_details].presence || {}
      end

      def components
        raw[:components].values.map do |component_params|
          next unless use_component?(component_params)

          product = bundled_products.detect { |p| p.id == component_params[:product_id] }
          next unless product.present?

          variants = matching_variants(product, component_params)
          next unless variants.present?

          variants.map do |variant|
            variant.merge(
              product: product,
              product_id: component_params[:product_id],
              quantity: component_params[:quantity]
            )
          end
        end.compact
      end

      private

      def use_component?(component_params)
        component_params[:quantity].to_i.positive? && (
          Array.wrap(component_params[:skus]).any? ||
          component_params[:details].any? do |_detail, detail_params|
            Array.wrap(detail_params[:values]).compact.any?
          end
        )
      end

      def matching_variants(product, component_params)
        skus = Array.wrap(component_params[:skus]).reject(&:blank?)
        return sku_based_variants(product, skus) if skus.present?

        selected_details = filtered_details(component_params[:details])

        product.variants.map do |variant|
          details = intersecting_details(selected_details, variant.details)
          next unless details.present?

          {
            variant: variant,
            sku: variant.sku,
            details: transform_details(variant, details, component_params[:details])
          }
        end.compact
      end

      def sku_based_variants(product, skus)
        skus.map do |sku|
          variant = product.variants.detect { |v| v.sku == sku }
          next unless variant.present?

          {
            variant: variant,
            sku: variant.sku,
            details: variant.details
          }
        end
      end

      def filtered_details(component_details_params)
        component_details_params.each_with_object({}) do |(detail, params), hash|
          next unless params[:values].present?
          hash[detail.to_s] = params[:values]
        end
      end

      def intersecting_details(selected_details, variant_details)
        selected_details.each_with_object({}) do |(detail, values), hash|
          intersection = variant_details[detail] & values
          return {} unless intersection.present?
          hash[detail] = intersection
        end
      end

      def transform_details(variant, details, component_details_params)
        component_details_params.each do |key, detail_params|
          detail = key.to_s
          name = detail_params[:rename].presence || detail

          if detail_params[:copy].to_s =~ /true/i
            details[name] = details.delete(detail) || variant.details[detail]
          else
            details.delete(detail)
          end
        end

        details
      end
    end
  end
end
