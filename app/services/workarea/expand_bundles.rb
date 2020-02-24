module Workarea
  class ExpandBundles
    def initialize(order)
      @persisted_order = order
    end

    def perform
      return unless @persisted_order.placed?

      order.items.select(&:bundle?).each do |item|
        bundled_items = order.bundled_items.find_for_bundle_item_id(item.id)
        next unless bundled_items.present?

        copy_bundled_items(bundled_items)
        devalue_bundle(item)
      end

      save_order
    end

    def order
      @order ||= @persisted_order.clone.tap do |result|
        result.id = @persisted_order.id # Ensure this isn't persisted
        result.attributes = clone_order_attributes
        result
      end
    end

    def clone_order_attributes
      @persisted_order.as_document.except('_id', 'id')
    end

    def save_order
      @persisted_order.update!(order.as_document.reverse_merge(items: []))
    end

    def copy_bundled_items(bundled_items)
      bundled_items.each do |item|
        order.items.build(item.as_document)
      end
    end

    def devalue_bundle(item)
      item.total_value = 0.to_m
      item.total_price = 0.to_m

      item.price_adjustments.each do |adjustment|
        adjustment.data['distributed_to_bundled_items'] = true
        adjustment.data['original_amount'] = adjustment.amount.to_f
        adjustment.amount = 0.to_m
      end
    end
  end
end
