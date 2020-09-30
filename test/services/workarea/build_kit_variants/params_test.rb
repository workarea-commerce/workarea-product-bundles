require 'test_helper'

module Workarea
  class BuildKitVariants
    class ParamsTest < TestCase
      def products
        @products ||= [
          create_product(
            id: 'PROD1',
            variants: [
              {
                sku: 'SKU1-1',
                regular: 5.to_m,
                details: { 'Color' => %w(Blue), 'Size' => %w(Small) }
              },
              {
                sku: 'SKU1-2',
                regular: 6.to_m,
                details: { 'Color' => %w(Blue), 'Size' => %w(Medium) }
              }
            ]
          )
        ]
      end

      def test_variant
        assert_equal({}, Params.new({}).variant)
        assert_equal(
          { product_id: '123' },
          Params.new(variant: { product_id: '123' }).variant
        )
      end

      def test_new_details?
        refute(Params.new({}).new_details?)
        refute(Params.new(variant: { new_details: 'false' }).new_details?)
        assert(Params.new(variant: { new_details: 'true' }).new_details?)
        assert(Params.new(variant: { new_details: true }).new_details?)
      end

      def test_calculate_pricing?
        refute(Params.new({}).calculate_pricing?)
        refute(Params.new(variant: { calculate_pricing: 'false' }).calculate_pricing?)
        assert(Params.new(variant: { calculate_pricing: 'true' }).calculate_pricing?)
        assert(Params.new(variant: { calculate_pricing: true }).calculate_pricing?)
      end

      def test_custom_price
        assert_nil(Params.new({}).custom_price)
        assert_equal('1.25', Params.new(variant: { price: '1.25' }).custom_price)
      end

      def test_new_details
        assert_equal({}, Params.new({}).new_details)
        assert_equal(
          %w(Color Red),
          Params.new(new_details: %w(Color Red)).new_details
        )
      end

      def test_components
        params = {
          '1' => {
            product_id: 'PROD1',
            quantity: 1,
            details: { 'Size' => { copy: true, values: %w(Small) } }
          }
        }

        components =
          Params.new(bundled_products: products, components: params).components

        assert_equal(1, components.size)
        assert_equal(1, components.first.size)

        component = components.first.first
        assert_equal('SKU1-1', component[:sku])
        assert_equal('SKU1-1', component[:variant].sku)
        assert_equal('PROD1', component[:product_id])
        assert_equal('PROD1', component[:product].id)
        assert_equal({ 'Size' => %w(Small) }, component[:details])
        assert_equal(1, component[:quantity])

        params = {
          '1' => {
            product_id: 'PROD1',
            quantity: 1,
            details: {
              'Size' => { copy: true, rename: 'New Size', values: %w(Small Medium) },
              'Color' => { copy: false, value: %w(Blue) }
            }
          }
        }

        components =
          Params.new(bundled_products: products, components: params).components

        assert_equal(1, components.size)
        assert_equal(2, components.first.size)

        component = components.first.first
        assert_equal('SKU1-1', component[:sku])
        assert_equal({ 'New Size' => %w(Small) }, component[:details])

        component = components.first.second
        assert_equal('SKU1-2', component[:sku])
        assert_equal({ 'New Size' => %w(Medium) }, component[:details])

        params['1'][:quantity] = 0
        assert_equal(
          [],
          Params.new(bundled_products: products, components: params).components
        )

        params['1'][:quantity] = 1
        params['1'][:product_id] = 'PROD5'
        assert_equal(
          [],
          Params.new(bundled_products: products, components: params).components
        )

        params['1'][:product_id] = 'PROD1'
        params['1'][:details]['Size'][:values] = %w(Purple)
        assert_equal(
          [],
          Params.new(bundled_products: products, components: params).components
        )

        params = {
          '1' => {
            product_id: 'PROD1',
            quantity: 1,
            details: {
              'Size' => { copy: true, rename: 'New Size', values: %w(Small Medium) },
              'Color' => { copy: true, value: [] }
            }
          }
        }

        components =
          Params.new(bundled_products: products, components: params).components

        component = components.first.first
        assert_equal('SKU1-1', component[:sku])
        assert_equal(
          { 'New Size' => %w(Small), 'Color' => %w(Blue) },
          component[:details]
        )

        component = components.first.second
        assert_equal('SKU1-2', component[:sku])
        assert_equal(
          { 'New Size' => %w(Medium), 'Color' => %w(Blue) },
          component[:details]
        )
      end
    end
  end
end
