module Workarea
  module Admin
    class CreateCatalogProductKitsController < CreateCatalogProductsController
      include BundleCreation
      include BulkVariantSaving

      def index
        render :setup
      end

      def create
        @product.attributes = params[:product]

        if @product.save
          flash[:success] = t('workarea.admin.create_catalog_products.flash_messages.saved')
          redirect_to bundled_products_create_catalog_product_kit_path(@product)
        else
          render :setup, status: :unprocessable_entity
        end
      end

      def edit
        render :setup
      end

      def bundled_products
        options = view_model_options.dup
        options[:q] ||= ''
        options[:q] += " -#{Workarea.config.product_bundle_templates.join(',')}"

        search = Search::AdminProducts.new(options)
        @search = SearchViewModel.new(search, options)
      end

      def variants
        @variants = VariantViewModel.wrap(@product.variants)
      end

      def save_variants
        params[:variants].each do |attrs|
          variant =
            if attrs['id'].present?
              @product.variants.detect { |v| v.id.to_s == attrs['id'] }
            end

          if attrs[:sku].present?
            save_variant_on_product(@product, variant: variant, attributes: attrs)
          elsif variant.present?
            variant.destroy
          end
        end

        flash[:success] = t('workarea.admin.create_catalog_products.flash_messages.variants_saved')
        redirect_to images_create_catalog_product_path(@product)
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
        redirect_to details_create_catalog_product_kit_path(@product)
      end

      def details
        @filters = @product.filters.presence || build_filters_from_options
        @details = @product.details.presence || build_details_from_products
      end

      def save_details
        @product.filters = HashUpdate.new(original: @product.filters, updates: params[:filters]).result
        @product.details = HashUpdate.new(original: @product.details, updates: params[:details]).result
        @product.save!

        flash[:success] = t('workarea.admin.create_catalog_products.flash_messages.saved')
        redirect_to content_create_catalog_product_kit_path(@product)
      end

      def content
      end

      def save_content
        @product.update_attributes!(params[:product])
        flash[:success] = t('workarea.admin.content_blocks.flash_messages.saved')
        redirect_to categorization_create_catalog_product_kit_path(@product)
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
    end
  end
end
