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
        post :preview_variants
        post :save_variants
        get :bundled_product

        get :manage_variants
        get :edit_variant, path: 'variant/:sku'
        patch :update_variant, path: 'variant/:sku'
        delete :destroy_variant, path: 'variant/:sku'
        delete :destroy_all_variants

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
