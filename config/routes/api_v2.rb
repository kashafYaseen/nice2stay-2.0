namespace :api do
  namespace :v2 do
    resource :profiles, only: [:create, :show, :update] do
      post :update_password
    end
    resource :sessions, only: [:create, :update]
    resource :omniauths, only: [:create, :update]
    resources :lodgings, only: [:index, :show] do
      resources :gc_rooms, only: [:show]
      resource :invoices, only: [:show]
      resources :reviews, only: [:index]
      resources :places, only: [:index]

      get :cumulative_price, on: :collection
      get :options, on: :member
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
  end
end
