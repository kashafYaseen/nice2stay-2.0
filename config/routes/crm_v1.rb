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
      resources :owners do
        get :resend_invitation, on: :member
      end
      resources :regions
      resources :campaigns
      resources :custom_texts
      resources :amenity_categories
      resources :cleaning_costs
      resources :lodging_categories
      resources :place_categories
    end

    namespace :owner do
      devise_for :owner
      resource :sessions, only: [:create, :update]
      resources :invitations
    end
  end
end
