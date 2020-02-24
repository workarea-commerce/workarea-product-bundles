module Workarea
  module Catalog
    class VariantComponent
      include ApplicationDocument

      field :product_id, type: String
      field :sku, type: String
      field :quantity, type: Integer, default: 1

      embedded_in :variant,
        class_name: 'Workarea::Catalog::Variant',
        inverse_of: :components,
        touch: true
    end
  end
end
