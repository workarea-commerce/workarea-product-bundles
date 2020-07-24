require 'test_helper'

module Workarea
  class Order
    class BundledItemTest < TestCase
      def test_bundled_item
        item = Order::Item.new
        refute(item.bundled_item?)

        item.bundle_item_id = '123'
        assert(item.bundled_item?)
      end

      def test_bundle?
        item = Order::Item.new
        refute(item.bundle?)

        item.product_attributes['product_ids'] = [1, 2]
        assert(item.bundle?)
      end

      def test_kit?
        item = Order::Item.new
        refute(item.kit?)

        item.product_attributes['product_ids'] = [1, 2]
        refute(item.kit?)

        item.product_attributes['variants'] = [
          { 'components' => { 'sku' => 'SKU' } }
        ]
        assert(item.kit?)

        item.product_attributes['variants'] = [
          { 'sku' => 'SKU' },
          { 'sku' => 'SKU2', 'components' => { 'sku' => 'SKU1' } }
        ]
        refute(item.kit?)
      end
    end
  end
end
