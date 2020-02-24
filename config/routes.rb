Workarea::Admin::Engine.routes.draw do
  scope '(:locale)', constraints: Workarea::I18n.routes_constraint do
    resources :create_catalog_product_bundles, except: :show do
      member do
        get :bundled_products

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

    resources :create_catalog_product_kits, except: :show do
      member do
        get :bundled_products

        get :variants
        post :save_variants

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
    post 'cart/items/bundle', to: 'cart_items#bundle', as: :bundle_cart_items

    resources :products, only: [] do
      member { get :bundle_details }
    end
  end
end
