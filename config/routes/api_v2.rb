namespace :api do
  namespace :v2 do
    resource :profiles, only: [:create]
    resource :sessions, only: [:create, :update]
    resources :lodgings, only: [:index, :show] do
      resource :invoices, only: [:show]
      resources :reviews, only: [:index]

      get :cumulative_price, on: :collection
      get :options, on: :member
    end
    resources :pages, only: [] do
      get :home, on: :collection
    end
    resource :filters, only: [:show]
    resources :autocompletes, only: [:index]
  end
end
