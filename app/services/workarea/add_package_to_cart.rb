module Workarea
  class AddPackageToCart
    attr_reader :items

    def initialize(order, params)
      @items = []

      # ActionController::Parameters has no #map
      params[:items].each do |_, item|
        @items << Item.new(order, item)
      end
    end

    def save
      items.all?(&:save)
    end

    def errors
      items.flat_map(&:errors)
    end

    class Item
      attr_reader :order, :params

      def initialize(order, params)
        @order = order
        @params = params
      end

      def errors
        @errors ||= []
      end

      def valid?
        (!customizations.present? || customizations.valid?).tap do |valid|
          customizations.errors.full_messages unless valid
        end
      end

      def save
        return false unless valid?
        order.add_item(item_params)
      end

      def item_params
        params
          .permit(:product_id, :sku, :quantity)
          .merge(customizations: customizations)
          .merge(item_details)
      end

      private

      def product_id
        @product_id ||= if params[:product_id].present?
          params[:product_id]
                        elsif params[:sku].present?
                          Catalog::Product.find_by_sku(params[:sku]).id
        end
      end

      def customizations
        @customizations ||= Catalog::Customizations.find(product_id, params)
      end

      def customization_params
        ActionController::Parameters.new(
          customizations.try(:to_h) || {}
        )
      end

      def item_details
        ActionController::Parameters.new(
          OrderItemDetails.find!(params[:sku]).to_h
        ).permit!
      end
    end
  end
end
