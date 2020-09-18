namespace :api do
  namespace :v1 do
    namespace :room_raccoon do
      resources :lodgings
      resources :availabilities, only: [:create]
      resources :prices, only: [:create]
    end

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
  end
end
