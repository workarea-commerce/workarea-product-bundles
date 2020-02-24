module Workarea
  class ProductKitSeeds
    def perform
      puts 'Adding product kits...'

      10.times do
        kit = create_product

        category = Workarea::Catalog::Category.sample
        category.product_ids.push(kit.id)
        category.save!
      end
    end

    private

    def create_product
      Sidekiq::Callbacks.disable do
        sizes = Workarea.config.search_facet_size_sort
        colors = Array.new(3) { Faker::Commerce.color.titleize }

        bundled_products =
          Workarea::Catalog::Product.sample(3).reject(&:bundle?)

        product = Catalog::Product.new(
          name: "#{Faker::Commerce.product_name} Kit",
          template: 'option_selects',
          product_ids: bundled_products.map(&:id),
          created_at: (0..3).to_a.sample.days.ago
        )

        3.times do
          sku = Faker::Code.isbn
          sku_price = Faker::Commerce.price.to_m

          components =
            bundled_products.each_with_object([]) do |product, components|
              components << {
                product_id: product.id,
                sku: product.skus.sample,
                quantity: (1..3).to_a.sample
              }
            end

          variant = product.variants.build(
            sku: sku,
            details: { 'Size' => sizes.sample, 'Color' => colors.sample },
            components: components
          )

          Inventory::Sku.create!(
            id: sku,
            policy: 'defer_to_components',
            component_quantities: variant.component_quantities
          )

          Fulfillment::Sku.create!(
            id: sku,
            policy: 'bundle'
          )

          components_price =
            Pricing::Sku.in(id: variant.components.map(&:sku)).sum do |sku|
              component = variant.components.detect { |c| c.sku == sku.id }
              sku.sell_price * component.quantity
            end

          Pricing::Sku.create!(
            id: sku,
            msrp: components_price,
            tax_code: '001',
            prices: [{ regular: components_price * 0.9 }]
          )
        end

        sizes = product.variants.map { |v| v.details['Size'] }
        colors = product.variants.map { |v| v.details['Color'] }

        product.filters = { 'Size' => sizes.uniq, 'Color' => colors.uniq }
        product.description = Faker::Hipster.paragraph
        product.save!
        product
      end
    end
  end
end
