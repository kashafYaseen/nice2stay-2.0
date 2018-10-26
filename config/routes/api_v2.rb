namespace :api do
  namespace :v2 do
    resources :lodgings
    resources :users
    resource :sessions, only: [:create, :update]
  end
end
