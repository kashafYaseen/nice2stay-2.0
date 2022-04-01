namespace :api do
  namespace :v1 do
    resource :room_raccoon, only: :create, module: :room_raccoon

    resources :lodgings do
      get :reindex, on: :collection
    end
    resources :reservations
    resources :campaigns
    resources :amenities, only: [:create]
    resources :experiences, only: [:create]
    resources :countries, only: [:create]
    resources :bookings, only: [:create]
    resources :pages, only: [:create]
    resources :users, only: [:create]
    resources :custom_texts, only: [:create]
    resources :reviews, only: [:create]
    resources :places, only: [:create]
    resources :gc_offers, only: [:create]
    localized do
      resources :experiences, only: [:index]
    end
    resources :owners, only: [:create]
    resources :vouchers, only: [:create]
  end
end
