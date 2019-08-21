module Workarea
  module Storefront
    class ProductTemplates::PackageViewModel < ProductViewModel
      delegate :has_price_range?, :price, :display_min_price,
               :display_max_price, :display_price, :has_msrp_range?,
               :msrp?, :msrp, :msrp_min, :msrp_max, :sale_starts_at,
               :sale_ends_at, to: :pricing

      def primary_image
        product_image = super
        return product_image unless product_image.placeholder?

        @primary_image ||=
          packaged_products
          .map(&:images)
          .flatten
          .reject(&:placeholder?)
          .first ||
          Catalog::ProductPlaceholderImage.cached
      end

      def show_panel?
        false
      end

      def pricing
        @pricing ||=
          options[:pricing] ||
          Pricing::Collection.new(packaged_products.map(&:skus).flatten)
      end
    end
  end
end
