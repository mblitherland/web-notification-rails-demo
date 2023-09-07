Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  post "/disable", to: "home#disable"
  post "/enable", to: "home#enable"
  post "/push_to_me", to: "home#push_to_me"
  post "/push_to_all", to: "home#push_to_all"

  # root "articles#index"
  root to: "home#index"
end
