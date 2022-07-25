namespace :api do
  namespace :v3 do
    resource :carts, only: [:show]
    resources :autocompletes, only: [:index]
  end
end
