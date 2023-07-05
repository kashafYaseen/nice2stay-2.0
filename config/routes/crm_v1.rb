namespace :crm do
  namespace :v1 do
    namespace :admin_user do
      resource :sessions, only: [:create, :update]
      resources :amenities
      resources :experiences
      resources :places
      resources :countries
      resources :regions
      resources :campaigns
      resources :custom_texts
      resources :amenity_categories
      resources :cleaning_costs
      resources :lodging_categories
      resources :place_categories
    end
  end
end
