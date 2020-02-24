module Workarea
  class AddBundledItemsToOrder
    def initialize(order, bundle_item, items_params)
      @order = order
      @bundle_item = bundle_item
      @items_params = items_params
    end

    def perform
      @items_params
        .map(&method(:get_full_params))
        .compact
        .map(&method(:add_to_order))
        .all?

    rescue StandardError => e
      @order.bundled_items_for(@bundle_item.id).each(&:destroy!)
      @bundle_item.destroy!
      raise e
    end

    def get_full_params(item_params)
      quantity = item_params[:quantity].to_i
      return if quantity.zero?

      AddMultipleCartItems::Item.new(@order, item_params)
        .item_params
        .merge(
          bundle_item_id: @bundle_item.id,
          bundle_quantity: quantity,
          quantity: quantity * @bundle_item.quantity
        )
    end

    def add_to_order(item_params)
      @order.add_bundled_item(item_params)
    end
  end
end
