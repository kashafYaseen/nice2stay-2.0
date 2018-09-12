require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :owners
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :api do
    namespace :v1 do
      resources :lodgings
      resources :reservations
      resources :campaigns
      resources :amenities, only: [:create]
      resources :experiences, only: [:create]
      resources :countries, only: [:create]
    end

    namespace :v2 do
      resources :lodgings
      resources :users
      resource :sessions, only: [:create, :update]
    end
  end

  get '/privacy', to: 'home#privacy'
  get '/terms', to: 'home#terms'

  resources :announcements, only: [:index]
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users

  localized do
    resources :autocompletes, only: [:index]
    resources :lodgings, path: :accommodations do
      get :price_details, on: :member
    end
    resource :carts do
      get :remove, on: :member
    end
    resource :wishlists do
      get :remove, on: :member
      post :checkout
    end

    resources :countries, only: [:index]

    get '/:id', to: 'countries#show', as: :country
    get '/:country_id/:id', to: 'regions#show', as: :country_region
    get '/', to: 'pages#home', as: :root
  end

  root 'pages#home'
  get "dashboard", to: "dashboard#index"

  namespace :dashboard do
    resources :reservations, only: [:index] do
      resources :reviews, except: [:show, :index]
    end
  end

  resources :reservations, only: [:create] do
    get :validate, on: :collection
  end
end
