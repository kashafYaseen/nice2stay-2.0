require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :owners
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :api do
    namespace :v1 do
      resources :lodgings
      resources :reservations
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
    resources :lodgings do
      get :price_details, on: :member
      collection do
        get :autocomplete
      end
    end
  end

  root to: 'pages#home'

  get "dashboard", to: "dashboard#index"

  namespace :dashboard do
    resources :reservations, only: [:index] do
      resources :reviews, except: [:show, :index]
    end
  end

  resources :reservations, only: [:create] do
    get :validate, on: :collection
  end

  resources :countries, only: [:index, :show] do
    resources :regions, only: [:show]
  end
end
