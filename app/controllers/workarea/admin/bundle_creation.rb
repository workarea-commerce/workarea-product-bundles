module Workarea
  module Admin
    module BundleCreation
      extend ActiveSupport::Concern

      included do
        required_permissions :catalog
        before_action :find_product
      end

      private

      def find_product
        model = if params[:id].present?
          Catalog::Product.find_by(slug: params[:id])
        else
          Catalog::Product.new(params[:product])
        end

        @product = ProductViewModel.new(model, view_model_options)
      end

      def standard_template_types
        Workarea.config.product_templates -
          Workarea.config.product_bundle_templates
      end

      def build_filters_from_products
        @product.bundled_products.each_with_object({}) do |product, result|
          product.variants.each do |variant|
            variant.details.each do |name, value|
              result[name] ||= []
              result[name] << value unless result[name].include?(value)
            end
          end

          result
        end
      end

      def build_details_from_products
        @product.bundled_products.reduce({}) do |result, product|
          product.details.each do |name, value|
            result[name] ||= []
            result[name] += Array.wrap(value)
            result[name].uniq!
            result
          end
        end
      end

      def build_filters_from_options
        @product.variants.reduce({}) do |result, variant|
          variant.details.each do |name, value|
            result[name] ||= []
            result[name] << value unless result[name].include?(value)
          end

          result
        end
      end
    end
  end
end
