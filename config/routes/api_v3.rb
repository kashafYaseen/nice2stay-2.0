namespace :api do
  namespace :v3 do
    resource :carts, only: [:show]
  end
end
