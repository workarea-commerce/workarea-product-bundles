module Workarea
  class ProductBundleSeeds
    def perform
      puts 'Adding product bundles...'

      10.times do
        package = create_product

        category = Workarea::Catalog::Category.sample
        category.product_ids.push(package.id)
        category.save!
      end
    end

    private

    def create_product
      Sidekiq::Callbacks.disable do
        model = Workarea::Catalog::Product.new
        bundled_products =
          Workarea::Catalog::Product.sample(4).reject(&:bundle?)

        model.id = rand(1_000_000)
        model.name = "Product Bundle #{rand(100_000)}"
        model.template = Workarea.config.product_bundle_templates.sample
        model.product_ids = bundled_products.map(&:id)

        model.filters = bundled_products.each_with_object({}) do |product, bundle_filters|
          product.filters.each do |filter_name, values|
            bundle_filters[filter_name] ||= []
            bundle_filters[filter_name].concat(Array(values)).uniq!
          end
        end

        model.description = Faker::Lorem.paragraph
        model.save!
        model
      end
    end
  end
end
