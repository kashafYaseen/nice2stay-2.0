require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get '/privacy', to: 'home#privacy'
  get '/terms', to: 'home#terms'
  namespace :admin do
    resources :users
    resources :announcements

    root to: "users#index"
  end

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

  
  root to: 'lodgings#homepage'

  resources :reservations, only: [:create] do
    get :validate, on: :collection
  end
end
