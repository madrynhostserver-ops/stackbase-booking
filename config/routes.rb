Rails.application.routes.draw do
  root "products#index"

  resources :products, only: %i[index show]
  resources :orders, only: %i[show create] do
    member do
      get :success
      get :tracking
    end
  end
  resource :session, only: %i[new create destroy]
  resource :registration, only: %i[new create]
  get "usercp", to: "usercp#show", as: :usercp
  namespace :admin do
    get "/", to: "dashboard#show", as: :dashboard
    resources :products do
      member do
        patch :toggle_active
      end
    end
    resources :orders, only: %i[index show update] do
      member do
        patch :assign_biker
      end
    end
    resource :pizzeria_setting, only: %i[edit update], path: "settings/pizzeria"
  end
  get "admincp", to: "admin/dashboard#show", as: :admincp
  get "bikercp", to: "bikercp#show", as: :bikercp
  patch "bikercp/orders/:id/location", to: "bikercp#update_location", as: :bikercp_order_location
  post "stripe/webhook", to: "stripe_webhooks#create"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
