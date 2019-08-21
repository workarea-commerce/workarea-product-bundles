require 'test_helper'

module Workarea
  class AddPackageToCartTest < TestCase
    setup :set_products

    def set_products
      @products = [
        create_product(
          id: 'PROD1',
          variants: [{ sku: 'SKU1', regular: 5.00 }]
        ),
        create_product(
          id: 'PROD2',
          variants: [{ sku: 'SKU2', regular: 10.00 }]
        )
      ]
    end

    def params
      @params ||= ActionController::Parameters.new(
        items: {
          1 => { product_id: 'PROD1', sku: 'SKU1', quantity: 2 },
          2 => { product_id: 'PROD2', sku: 'SKU2', quantity: 1 }
        }
      )
    end

    def test_save
      order = create_order

      add_to_cart = AddPackageToCart.new(order, params)

      result = add_to_cart.save
      order.reload

      assert(result)
      assert_equal(2, order.items.count)

      item = order.items.first
      assert_equal('PROD1', item.product_id)
      assert_equal('SKU1', item.sku)
      assert_equal(2, item.quantity)
    end
  end
end
