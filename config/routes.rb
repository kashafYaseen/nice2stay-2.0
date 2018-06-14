require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :owners
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :api do
    namespace :v1 do
      resources :lodgings
    end
  end

  get '/privacy', to: 'home#privacy'
  get '/terms', to: 'home#terms'

  resources :announcements, only: [:index]
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users

  resources :lodgings do
    get :price_details, on: :member
    collection do 
      get :autocomplete
    end
  end

  root to: 'pages#home'

  resources :reservations, only: [:create] do
    get :validate, on: :collection
  end
end
