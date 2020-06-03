module Workarea
  module Inventory
    module Policies
      class DeferToComponents < Base
        def displayable?
          sku.purchasable?
        end

        def available_to_sell
          sets = sku.component_inventory.map do |inventory|
            component_quantity = sku.component_quantities[inventory.id].to_i
            next unless component_quantity.positive?

            inventory.available_to_sell / component_quantity
          end

          sets.compact.min || 0
        end

        def purchase(quantity)
          sku.inc(purchased: quantity)
          nil
        end
      end
    end
  end
end
