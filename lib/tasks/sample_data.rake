namespace :dummy do
  desc 'Add sample data for the Dummy project.'
  task sample_data: :environment do
    require 'workarea/sample_data/task'

    # add require statement for new generators
    require 'workarea/sample_data/generators/package_product_generator'

    # Inserts a discount generator from host generator before ShippingMethodsGenerator
    Workarea::SampleData.generators.insert(
      Workarea::SampleData::Generators::PackageProductGenerator,
      Workarea::SampleData::Generators::ProductsGenerator
    )
    Workarea::SampleData::Task.run
  end
end
