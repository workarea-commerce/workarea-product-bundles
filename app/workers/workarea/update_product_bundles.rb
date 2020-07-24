module Workarea
  class UpdateProductBundles
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { Catalog::Product => :destroy },
      unique: :until_executing
    )

    def perform(id)
      Sidekiq::Callbacks.inline do
        bundles = Catalog::Product.where(product_ids: id)
        bundles.each do |bundle|
          bundle.product_ids.delete(id)

          bundle.variants.each do |variant|
            variant.components.where(product_id: id).destroy_all
          end

          bundle.save
        end
      end
    end
  end
end
