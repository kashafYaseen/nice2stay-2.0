namespace :api do
  namespace :v2 do
    resource :profiles, only: [:create, :show, :update] do
      post :update_password
      post :valid
    end
    resource :sessions, only: [:create, :update]
    resource :omniauths, only: [:create, :update]
    resources :lodgings, only: [:index, :show] do
      resources :gc_rooms, only: [:show]
      resource :invoices, only: [:show]
      resources :reviews, only: [:index]
      resources :places, only: [:index]
      resources :room_types do
        get :cumulative_price, on: :collection
      end

      resources :room_rates do
        get :cumulative_price, on: :member
      end

      get :options, on: :member

      collection do
        get :cumulative_price
        get :recommendations
      end
    end
    resources :pages, only: [] do
      get :home, on: :collection
    end
    resource :filters, only: [:show]
    resources :autocompletes, only: [:index]
    resources :favourites, only: [:index, :create, :destroy]
    resources :trips, only: [:index, :create, :update, :destroy] do
      resources :trip_members, only: [:new, :create, :destroy]
    end
    resources :bookings, only: [:index, :show] do
      resource :payments, only: [:create]
    end
    resource :carts do
      post :remove, on: :member
    end
    resources :countries, only: [:index]
    resources :regions, only: [:index]
    resources :leads, only: [:create]
    resources :reservations, only: [] do
      resources :reviews, only: [:create]
    end

    resource :open_gds, only: :create
    resources :amenities, only: [:index]
    resources :recent_searches, only: [:index, :create] do
      delete :destroy, on: :collection
    end
    resources :visited_lodgings, only: [:index, :create] do
      delete :destroy, on: :collection
    end
  end
end
