module Workarea
  module Admin
    class CreateCatalogProductKitsController < CreateCatalogProductsController
      include BundleCreation

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
        options[:q] += " -product_bundle"

        search = Search::AdminProducts.new(options)
        @search = SearchViewModel.new(search, options)
      end

      def bundled_product
        @bundled_product = @product.bundled_products.detect do |bundled_product|
          bundled_product.id == params[:bundled_product_id]
        end
      end

      def variants
        models = @product.variants.select(&:persisted?)
        @variants = VariantViewModel.wrap(models, view_model_options)
      end

      def preview_variants
        @summary = BuildKitVariants.new(@product, params).summary
      end

      def save_variants
        result = BuildKitVariants.new(@product, params).perform

        flash[:success] = t('workarea.admin.create_catalog_product_kits.flash_messages.variants_saved')

        if params[:add_more_variants].to_s =~ /true/i
          redirect_to variants_create_catalog_product_kit_path(@product)
        else
          redirect_to manage_variants_create_catalog_product_kit_path(@product)
        end
      end

      def manage_variants
        models = @product.variants.select(&:persisted?)
        @variants = VariantViewModel.wrap(models, view_model_options)
      end

      def edit_variant
        model = @product.variants.detect { |v| v.sku == params[:sku] }
        @variant = VariantViewModel.wrap(model, view_model_options)
      end

      def update_variant
        @variant = @product.variants.detect { |v| v.sku == params[:sku] }

        if UpdateKitVariant.new(@variant, params.to_unsafe_h).perform
          flash[:success] = t('workarea.admin.catalog_variants.flash_messages.saved')
         redirect_to manage_variants_create_catalog_product_kit_path(@product)
        else
          @variant = VariantViewModel.wrap(@variant)

          flash[:error] = t('workarea.admin.catalog_variants.flash_messages.changes_error')
          render :edit_variants
        end
      end

      def destroy_variant
        variant = @product.variants.detect { |v| v.sku == params[:sku] }
        variant.destroy

        flash[:success] = t('workarea.admin.catalog_variants.flash_messages.removed')
        redirect_to manage_variants_create_catalog_product_kit_path(@product)
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
