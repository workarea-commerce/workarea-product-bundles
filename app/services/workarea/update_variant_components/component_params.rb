module Workarea
  class UpdateVariantComponents
    class ComponentParams
      attr_reader :variant, :params

      def initialize(variant, params)
        @variant = variant
        @params = params
      end

      def save
        return remove if remove?
        update? ? update : add
      end

      def add
        product_id =
          params[:product_id] ||
          Catalog::Product.find_by_sku(params[:sku])&.id

        return unless product_id

        variant.components.build(params.merge(product_id: product_id))
      end

      def remove?
        params[:remove].to_s =~ /true/i
      end

      def remove
        variant.components = variant.components.reject do |component|
          component.id.to_s == params[:id]
        end
      end

      def update?
        !remove? && params[:id].present?
      end

      def update
        component = variant.components.detect { |c| c.id.to_s == params[:id] }
        component.attributes = params.except(:id, :remove)
      end
    end
  end
end
