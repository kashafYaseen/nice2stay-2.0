Rails.application.routes.draw do
  draw :api_v1
  draw :seo
  draw :sidekiq

  get 'loaderio-92ffa9c2f5ca47c35049bbaa39b7c1b0', to: 'pages#loader' # This is used for stress testing through loader.io
  get '404', to: 'pages#page_not_found', as: :page_not_found
  devise_for :users, only: :omniauth_callbacks, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  localized do
    devise_for :users, skip: :omniauth_callbacks, controllers: { registrations: 'users/registrations', confirmations: 'users/confirmations', sessions: 'users/sessions', passwords: 'users/passwords', invitations: 'users/invitations' }
    devise_for :admin_users, ActiveAdmin::Devise.config
    ActiveAdmin.routes(self) rescue ActiveAdmin::DatabaseHitDuringLoad
    draw :api_v2
    draw :api_v3
    draw :crm_v1

    devise_scope :user do
      get "users/edit/password", to: 'users/registrations#edit_password', as: :user_edit_password
      post "users/edit/password", to: 'users/registrations#update_password', as: :user_update_password
    end

    resources :announcements, only: [:index]
    resources :autocompletes, only: [:index]
    resources :lodgings, only: [:index, :show], path: :accommodations do
      resources :guest_centric_offers, only: [:show] do
        post :rates, on: :collection
      end
      post :index, on: :collection
      get :price_details, on: :member
      get :quick_view, on: :member
      get :cumulative_price, on: :collection
      get :calendar, on: :member
      resources :booking_expert_lodgings, only: [:show] do
        post :rates, on: :collection
      end
    end
    resource :carts do
      get :remove, on: :member
      get :details, on: :member
    end

    resources :wishlists, only: [:new, :create, :destroy]

    resources :feedbacks, only: [:new, :create]
    resources :countries, only: [:index]
    resources :leads, only: [:create, :show]

    namespace :users do
      resources :social_registrations, only: [:new, :create, :show] do
        put :update, on: :collection
      end
    end

    resources :reservations, only: [:create] do
      get :validate, on: :collection
    end

    resources :trips do
      get :public, on: :member
      resources :trip_members, only: [:new, :create, :destroy]
    end

    namespace :dashboard do
      resources :bookings, only: [:show] do
        resource :payment, only: [:create] do
          post :update_status
        end
      end
      resources :reservations, only: [:index, :destroy] do
        member do
          post :accept_option
          post :cancel_option
        end
        resources :reviews, except: [:show, :index]
      end

      resources :notifications, only: [:index] do
        get :mark_as_read, on: :collection
      end

      resources :vouchers, only: [:index]
    end

    resources :pages, only: [:show]
    resources :newsletter_subscriptions, only: [:create]
    resources :vouchers, only: [:new, :create, :show] do
      post :update_status
    end

    get "dashboard", to: "dashboard#index"
    get '/lodgings/guest_centric', to: "guest_centric_offers#index"
    get '/:id', to: 'countries#show', as: :country
    get '/:country_id/:id', to: 'regions#show', as: :country_region
    # get '/', to: 'pages#home', as: :root
  end
  # root 'pages#home'
  post '/', to: 'dashboard/payments#update_status' unless Rails.env.production?
end
