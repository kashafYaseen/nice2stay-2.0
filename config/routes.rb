Rails.application.routes.draw do
  draw :api_v1
  draw :api_v2
  draw :seo
  draw :sidekiq

  get '404', to: 'pages#page_not_found'

  localized do
    devise_for :users, controllers: { registrations: 'users/registrations', confirmations: 'users/confirmations', sessions: 'users/sessions', passwords: 'users/passwords' }
    devise_for :admin_users, ActiveAdmin::Devise.config
    ActiveAdmin.routes(self)

    resources :announcements, only: [:index]
    resources :autocompletes, only: [:index]
    resources :lodgings, only: [:index, :show], path: :accommodations do
      post :index, on: :collection
      get :price_details, on: :member
      get :calendar, on: :member
    end
    resource :carts do
      get :remove, on: :member
      get :details, on: :member
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

      resources :notifications, only: [:index] do
        get :mark_as_read, on: :collection
      end
    end

    resources :pages, only: [:show] do
      get :over_ons, path: 'over-ons', on: :collection
    end

    get "dashboard", to: "dashboard#index"
    get '/privacy', to: 'home#privacy'
    get '/terms', to: 'home#terms'
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
