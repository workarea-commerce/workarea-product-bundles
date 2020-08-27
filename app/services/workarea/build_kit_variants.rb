module Workarea
  class BuildKitVariants
    attr_reader :product, :params

    def initialize(product, params)
      @product = product
      @params = params
    end

    def perform
      prime_related_skus
      variants.each(&:save!) && product.save!
    end

    def summary
      prime_related_skus
      variants.each(&:build)

      {
        variants: variants.count,
        prices: variants.map(&:pricing_sku).map(&:sell_price).uniq,
        details: variants.each_with_object(Hash.new([])) do |variant, details|
          variant.model.details.each do |key, value|
            details[key] = (details[key] + value).uniq
          end
        end
      }
    end

    def variants
      @variants ||= component_groups.map do |components|
        Variant.new(self, components)
      end
    end

    def component_groups
      return @component_groups if defined?(@component_groups)

      pieces = params[:components].values.map do |skus_params|
        skus_params.map do |sku_params|
          next unless sku_params[:selected] =~ /true/i

          product = bundled_products.detect { |p| p.id == sku_params[:product_id] }
          next unless product.present?

          {
            product_id: product.id,
            sku: sku_params[:sku],
            quantity: sku_params[:quantity],
            product: product,
            variant: product.variants.detect { |v| v.sku == sku_params[:sku] }
          }
        end.compact
      end.reject(&:blank?)

      @component_groups = pieces.shift.product(*pieces)
    end

    def next_variant_sku
      prefix = params[:variant][:sku]
      return prefix if component_groups.one? && prefix.present?

      "#{prefix || product.id}-#{SecureRandom.hex(2).upcase}"
    end

    def copy_options?
      params[:variant][:copy_options] =~ /true/i
    end

    def calculate_pricing?
      params[:variant][:calculate_pricing] =~ /true/i
    end

    def bundled_products
      @bundled_products ||= Catalog::Product.in(id: product.product_ids)
    end

    def pricing
      @pricing ||= Pricing::Collection.new(
        component_groups.flatten.map { |c| c[:sku] }.uniq
      )
    end

    def prime_related_skus
      new_skus = variants.map(&:sku)
      pricing_skus = Pricing::Collection.new(new_skus)
      inventory_skus = Inventory::Collection.new(new_skus)
      fulfillment_skus = Fulfillment::Sku.in(id: new_skus).to_a

      variants.each do |variant|
        variant.inventory_sku = inventory_skus.for_sku(variant.sku)

        variant.pricing_sku =
          pricing_skus.detect { |s| s.id == variant.sku }.presence ||
          Pricing::Sku.new(id: variant.sku)

        variant.fulfillment_sku =
          fulfillment_skus.detect { |s| s.id == variant.sku }.presence ||
          Fulfillment::Sku.new(id: variant.sku)
      end
    end
  end
end
