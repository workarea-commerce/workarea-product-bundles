module Workarea
  module Inventory
    module Policies
      class DeferToComponents < Base
        def displayable?
          sku.purchasable?
        end

        def available_to_sell
          sets = sku.component_inventory.map do |inventory|
            inventory.available_to_sell / sku.component_quantities[inventory.id]
          end

          sets.min || 0
        end

        def purchase(quantity)
          sku.inc(purchased: quantity)
          nil
        end
      end
    end
  end
end
