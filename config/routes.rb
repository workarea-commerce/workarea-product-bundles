Workarea::Admin::Engine.routes.draw do
  scope '(:locale)', constraints: Workarea::I18n.routes_constraint do
    resources :create_catalog_package_products, except: :show do
      member do
        get :packaged_products

        get :details
        post :save_details

        get :images
        post :save_images

        get :content
        post :save_content

        get :categorization
        post :save_categorization

        get :publish
        post :save_publish
      end
    end
  end
end

Workarea::Storefront::Engine.routes.draw do
  scope '(:locale)', constraints: Workarea::I18n.routes_constraint do
    post 'cart/items/package', to: 'cart_items#package', as: :package_cart_items
  end
end
