require 'sidekiq/web'

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :lodgings
      resources :reservations
      resources :campaigns
      resources :amenities, only: [:create]
      resources :experiences, only: [:create]
      resources :countries, only: [:create]
      resources :bookings, only: [:create]
      resources :pages, only: [:create]
      resources :users, only: [:create]
      resources :custom_texts, only: [:create]
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
  authenticate :admin_user, lambda { |u| u.present? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  if ActiveRecord::Base.connection.table_exists? 'custom_text_translations'
    CustomText.find_each do |custom_text|
      get "en/#{custom_text.seo_path('en')}", to: "lodgings#index", defaults: { locale: :en, custom_text: custom_text.id }
      get "nl/#{custom_text.seo_path('nl')}", to: "lodgings#index", defaults: { locale: :nl, custom_text: custom_text.id }
    end
  end

  localized do
    devise_for :users, controllers: { registrations: 'users/registrations', confirmations: 'users/confirmations' }
    devise_for :admin_users, ActiveAdmin::Devise.config
    ActiveAdmin.routes(self)

    resources :autocompletes, only: [:index]
    resources :lodgings, only: [:index, :show], path: :accommodations do
      post :index, on: :collection
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
    resources :leads, only: [:create]

    namespace :dashboard do
      resources :bookings, only: [:show] do
        resource :payment, only: [:create] do
          post :update_status
        end
      end
      resources :reservations, only: [:index, :destroy] do
        member do
          post :accept_option
        end
        resources :reviews, except: [:show, :index]
      end

      resource :wishlists do
        get :remove, on: :member
        post :checkout
      end
    end

    resources :pages, only: [:show] do
      get :over_ons, path: 'over-ons', on: :collection
    end

    get "dashboard", to: "dashboard#index"
    get '/:id', to: 'countries#show', as: :country
    get '/:country_id/:id', to: 'regions#show', as: :country_region
    get '/', to: 'pages#home', as: :root
  end
  root 'pages#home'
  post '/', to: 'dashboard/payments#update_status' unless Rails.env.production?

  resources :reservations, only: [:create] do
    get :validate, on: :collection
  end
end
