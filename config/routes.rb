Rails.application.routes.draw do
  devise_for :users

  # Teams with nested memberships, invitations and games
  resources :teams do
    delete :leave, to: "memberships#leave"
    resources :memberships, only: [ :destroy ]
    resources :invitations, only: [ :create ] do
      member do
        patch :accept
        patch :refuse
      end
    end
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
