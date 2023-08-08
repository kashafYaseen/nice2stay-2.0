namespace :crm do
  namespace :v1 do
    namespace :admin_user do
      resource :sessions, only: [:create, :update]
      resources :amenities
      resources :experiences
      resources :places
      resources :countries do
        get :regions, on: :member
      end
      resources :regions
      resources :campaigns do
        get :options, on: :collection
      end
      resources :custom_texts
      resources :amenity_categories
      resources :cleaning_costs
      resources :lodging_categories
      resources :place_categories
    end
  end
end
