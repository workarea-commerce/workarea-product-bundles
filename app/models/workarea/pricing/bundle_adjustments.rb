module Workarea
  module Pricing
    class BundleAdjustments
      def initialize(order)
        @order = order
      end

      def adjust
        @order.items.select(&:bundle?).each(&method(:adjust_item))
      end

      def adjust_item(item)
        bundled_items = @order.bundled_items.select do |bundled_item|
          bundled_item.bundle_item_id == item.id.to_s
        end

        return unless bundled_items.present?

        item.price_adjustments.each_with_index do |adjustment, index|
          if index.zero?
            bundled_items_total = bundled_items.flat_map(&:price_adjustments).sum(&:amount)
            bundle_value_delta = bundled_items_total - adjustment.amount

            reduces_total = bundle_value_delta.positive?
            distributions =
              Workarea::Pricing::PriceDistributor.for_items(
                bundle_value_delta.abs,
                bundled_items
              ).results
          else
            reduces_total = adjustment.amount.negative?
            distributions =
              Workarea::Pricing::PriceDistributor.for_items(
                adjustment.amount.abs,
                bundled_items
              ).results
          end

          distributions.each do |id, delta|
            bundled_item = bundled_items.detect { |i| i.id == id }

            bundled_item.adjust_pricing(
              adjustment.attributes.deep_merge(
                'amount' => reduces_total ? (delta * -1) : delta,
                'description' => index.zero? ? 'Bundle Adjustment' : adjustment.description,
                'quantity' => bundled_item.quantity,
                'calculator' => self.class.name,
                'data' => {
                  'bundle_item_id' => item.id,
                  'original_calculator' => adjustment.calculator
                }
              )
            )
          end
        end

        bundled_items.each do |bundled_item|
          bundled_item.total_value =
            bundled_item.price_adjustments.reject do |adjustment|
              adjustment.price.in?(%w(tax shipping))
            end.sum(&:amount)

          bundled_item.total_price =
            bundled_item.price_adjustments.adjusting('item').sum
        end
      end
    end
  end
end
