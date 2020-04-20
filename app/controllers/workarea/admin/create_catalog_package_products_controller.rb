module Workarea
  module Admin
    class CreateCatalogPackageProductsController < CreateCatalogProductsController
      required_permissions :catalog
      before_action :find_product

      def index
        @product.template = 'package'
        render :setup
      end

      def create
        @product.attributes = params[:product]

        if @product.save
          flash[:success] = t('workarea.admin.create_catalog_products.flash_messages.saved')
          redirect_to packaged_products_create_catalog_package_product_path(@product)
        else
          render :setup, status: :unprocessable_entity
        end
      end

      def edit
        render :setup
      end

      def packaged_products
        options = view_model_options
        options[:q] ||= ''
        options[:q] += " -#{Workarea.config.package_product_templates.join(',')}"

        search = Search::AdminProducts.new(options)
        @search = SearchViewModel.new(search, options)
      end

      def images
      end

      def save_images
        if params[:updates].present?
          params[:updates].each do |id, attrs|
            image = @product.images.find(id)
            image.attributes = attrs
            image.save!
          end
        end

        if params[:images].present?
          params[:images].each do |attrs|
            @product.images.create!(attrs) if attrs[:image].present?
          end
        end

        flash[:success] = t('workarea.admin.create_catalog_products.flash_messages.saved')
        redirect_to details_create_catalog_package_product_path(@product)
      end

      def details
        @filters = @product.filters.presence || build_filters_from_products
        @details = @product.details.presence || build_details_from_products
      end

      def save_details
        @product.filters = HashUpdate.new(original: @product.filters, updates: params[:filters]).result
        @product.details = HashUpdate.new(original: @product.details, updates: params[:details]).result
        @product.save!

        flash[:success] = t('workarea.admin.create_catalog_products.flash_messages.saved')
        redirect_to content_create_catalog_package_product_path(@product)
      end

      def content
      end

      def save_content
        @product.update_attributes!(params[:product])
        flash[:success] = t('workarea.admin.content_blocks.flash_messages.saved')
        redirect_to categorization_create_catalog_package_product_path(@product)
      end

      def categorization
      end

      def save_categorization
        params[:category_ids].reject(&:blank?).each do |id|
          Catalog::Category.find(id).add_product(@product.id)
        end

        flash[:success] = t('workarea.admin.create_catalog_products.flash_messages.saved')
        render :categorization
      end

      def publish
      end

      def save_publish
        publish = SavePublishing.new(@product, params)

        if publish.perform
          flash[:success] = t('workarea.admin.create_catalog_products.flash_messages.product_created')
          redirect_to catalog_product_path(@product)
        else
          flash[:error] = publish.errors.full_messages
          render :publish
        end
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
          Workarea.config.package_product_templates
      end

      def build_filters_from_products
        @product.packaged_products.each_with_object({}) do |product, result|
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
        @product.packaged_products.reduce({}) do |result, product|
          product.details.each do |name, value|
            result[name] ||= []
            result[name] += Array.wrap(value)
            result[name].uniq!
            result
          end
        end
      end
    end
  end
end
