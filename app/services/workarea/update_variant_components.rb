module Workarea
  class UpdateVariantComponents
    def initialize(variant, components_params)
      @variant = variant
      @components_params = components_params.presence || []
    end

    def perform
      @components_params.each do |params|
        params.deep_symbolize_keys! if params.respond_to?(:deep_symbolize_keys!)

        if remove?(params)
          remove_component(params)
        elsif update?(params)
          update_component(params)
        else
          add_component(params)
        end
      end
    end

    def perform!
      perform && save!
    end

    private

    def remove?(params)
      params[:remove].to_s =~ /true/i
    end

    def remove_component(params)
      @variant.components = @variant.components.reject do |component|
        component.id.to_s == params[:id]
      end
    end

    def update?(params)
      !remove?(params) && params[:id].present?
    end

    def update_component(params)
      component = @variant.components.detect { |c| c.id.to_s == params[:id] }
      component.attributes = params.except(:id, :remove)
    end

    def add_component(params)
      product_id =
        params[:product_id] ||
        Catalog::Product.find_by_sku(params[:sku])&.id

      return unless product_id

      @variant.components.build(params.merge(product_id: product_id))
    end
  end
end
