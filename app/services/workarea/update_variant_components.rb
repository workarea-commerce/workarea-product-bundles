module Workarea
  class UpdateVariantComponents
    def initialize(variant, components_params)
      @variant = variant
      @components_params = components_params.presence || []
    end

    def perform
      @components_params.each do |params|
        params.deep_symbolize_keys! if params.respond_to?(:deep_symbolize_keys!)
        ComponentParams.new(@variant, params).save
      end
    end
  end
end
