module Workarea
  class ProductBundleSeeds
    def perform
      puts 'Adding product bundles...'

      create_products_from_file.each do |product|
        category = Workarea::Catalog::Category.sample
        category.product_ids.push(product.id)
        category.save!
      end
    end

    def create_products_from_file
      path = 'data/bundle_seeds.json'
      contents = File.read(Workarea::ProductBundles::Engine.root.join(path))
      products_data = JSON.parse(contents)

      products_data.map(&method(:create_product))
    end

    private

    def create_product(data)
      Sidekiq::Callbacks.disable do
        pricing_data = data['pricing']
        inventory_data = data['inventory']
        fulfillment_data = data['fulfillment']

        product = Catalog::Product.create!(
          data.except('pricing', 'inventory', 'fulfillment')
              .reverse_merge(description: Faker::Lorem.paragraph)
        )

        if pricing_data.present?
          pricing_data.each do |sku, pdata|
            sku = Pricing::Sku.new(pdata.reverse_merge(id: sku, tax_code: '001'))
            sku.save!(validate: false)
          end
        end

        if inventory_data.present?
          inventory_data.each do |sku, idata|
            inventory = Inventory::Sku.create!(idata.merge(id: sku))
            next unless product.kit?

            variant = product.variants.detect { |v| v.sku == sku }
            inventory.update!(component_quantities: variant.component_quantities)
          end
        end

        if fulfillment_data.present?
          fulfillment_data.each do |sku, fdata|
            Fulfillment::Sku.create!(fdata.merge(id: sku))
          end
        end

        product
      end
    end
  end
end
