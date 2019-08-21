module Workarea
  class PackageProductSeeds
    def perform
      puts 'Adding package products...'

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
        packaged_products =
          Workarea::Catalog::Product.sample(4).reject(&:package?)

        model.id = rand(1_000_000)
        model.name = "Package Product #{rand(100_000)}"
        model.template = Workarea.config.package_product_templates.sample
        model.product_ids = packaged_products.map(&:id)

        model.filters = packaged_products.each_with_object({}) do |product, package_filters|
          product.filters.each do |filter_name, values|
            package_filters[filter_name] ||= []
            package_filters[filter_name].concat(Array(values)).uniq!
          end
        end

        model.description = Faker::Lorem.paragraph
        model.save!
        model
      end
    end
  end
end
