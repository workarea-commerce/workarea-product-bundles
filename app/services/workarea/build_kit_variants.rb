module Workarea
  class BuildKitVariants
    attr_reader :product, :params

    def initialize(product, params)
      @product = product
      @params = Params.new(params.merge(bundled_products: bundled_products))
    end

    def perform
      prime_related_skus
      variants.each(&:save!) && product.save!
    end

    def summary
      prime_related_skus
      variants.each(&:build)
      all_details = variants.map(&:details)

      OpenStruct.new(
        variants: variants.count,
        prices: variants.map(&:pricing_sku).map(&:sell_price).uniq,
        details: all_details.each_with_object(Hash.new([])) do |details, hash|
          details.each { |key, value| hash[key] = (hash[key] + value).uniq }
        end,
        missing_details?: !variants.all?(&:has_details?),
        duplicate_details?: all_details.size != all_details.uniq.size,
        invalid_details?: variants.any?(&:invalid_details?)
      )
    end

    def variants
      @variants ||= component_groups.map do |components|
        Variant.new(self, components)
      end
    end

    def component_groups
      return @component_groups if defined?(@component_groups)
      pieces = params.components
      return [] unless pieces.present?
      @component_groups = pieces.shift.product(*pieces)
    end

    def next_variant_sku
      prefix = params.variant[:sku]
      return prefix if component_groups.one? && prefix.present?

      "#{prefix || product.id}-#{SecureRandom.hex(2).upcase}"
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
