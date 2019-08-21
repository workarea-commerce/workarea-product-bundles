module Workarea
  class UpdatePackageProducts
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { Catalog::Product => :destroy },
      unique: :until_executing
    )

    def perform(id)
      Sidekiq::Callbacks.inline do
        packages = Catalog::Product.where(product_ids: id)
        packages.each do |package|
          package.product_ids.delete(id)
          package.save
        end
      end
    end
  end
end
