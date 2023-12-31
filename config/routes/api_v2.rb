namespace :api do
  namespace :v2 do
    resource :profiles, only: [:create, :show, :update] do
      post :update_password
      post :valid
    end
    resource :sessions, only: [:create, :update]
    resource :passwords, only: [:create, :update]
    resource :omniauths, only: [:create, :update]
    resource :socials, only: :create do
      post :user_info, on: :collection
    end
    resources :lodgings, only: [:index, :show] do
      resources :gc_rooms, only: [:show]
      resource :invoices, only: [:show]
      resources :reviews, only: [:index]
      resources :places, only: [:index]
      get :calendar_build, on: :member
      get :calendar_departure, on: :member

      resources :room_rates do
        get :cumulative_price, on: :member
        get :calendar_build, on: :member
        get :calendar_departure, on: :member
      end

      get :options, on: :member

      collection do
        get :cumulative_price
        get :recommendations
      end

      resources :supplements, only: [:index, :show]
    end
    resources :pages, only: [:show] do
      collection do
        get :home
        get :reviews
        get :campaigns
      end
    end

    resources :custom_texts, only: [:index, :show]

    resources :reservations, only: [] do
      member do
        put :accept_option
        put :cancel_option
      end
    end

    resource :filters, only: [:show]
    resources :autocompletes, only: [:index]
    resources :favourites, only: [:index, :create, :destroy]
    resources :trips, only: [:index, :create, :show, :update, :destroy] do
      resources :trip_members, only: [:new, :create, :destroy]
    end

    resources :bookings, only: [:index, :show] do
      resource :payments, only: [:create] do
        put :update_status, on: :member
      end
    end

    namespace :payments do
      get :payment_method_details
      get :payment_methods
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
