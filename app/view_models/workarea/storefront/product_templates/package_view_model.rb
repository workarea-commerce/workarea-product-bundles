module Workarea
  module Storefront
    class ProductTemplates::PackageViewModel < ProductViewModel
      delegate :has_price_range?, :price, :display_min_price,
               :display_max_price, :display_price, :has_msrp_range?,
               :msrp?, :msrp, :msrp_min, :msrp_max, :sale_starts_at,
               :sale_ends_at, to: :pricing

      def pricing
        @pricing ||=
          options[:pricing] ||
          Pricing::Collection.new(bundled_products.map(&:skus).flatten)
      end
    end
  end
end
