Rails.application.routes.draw do
  devise_for :users

  # Teams with nested memberships and games
  resources :teams do
    resources :memberships, only: [ :create, :destroy ]
    resources :games, only: [ :index, :new, :create ]
  end

  # Games with nested proposals, guesses, and results
  resources :games, only: [ :show, :destroy ] do
    member do
      patch :start_guessing
      patch :finish
    end

    resources :proposals, only: [ :new, :create, :show ]
    resources :guesses, only: [ :new, :create ]

    resource :results, only: [ :show ]
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path - public home page
  root "home#index"
end
