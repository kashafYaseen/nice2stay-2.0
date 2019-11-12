namespace :api do
  namespace :v2 do
    resources :lodgings
    resource :profiles, only: [:create]
    resource :sessions, only: [:create, :update]
  end
end
