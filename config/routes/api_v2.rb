namespace :api do
  namespace :v2 do
    resource :profiles, only: [:create]
    resource :sessions, only: [:create, :update]
    resources :lodgings, only: [:index, :show] do
      get :cumulative_price, on: :collection
    end
  end
end
