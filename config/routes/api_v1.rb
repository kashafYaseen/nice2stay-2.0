namespace :api do
  namespace :v1 do
    resources :lodgings
    resources :reservations
    resources :campaigns
    resources :amenities, only: [:create]
    resources :experiences, only: [:create]
    resources :countries, only: [:create]
    resources :bookings, only: [:create]
    resources :pages, only: [:create]
    resources :users, only: [:create]
    resources :custom_texts, only: [:create]
  end
end
