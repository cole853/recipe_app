Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get "/recipes/search", to: "recipes#search"
  resources :recipes, except: [ "index" ]
  get "home/index"
  root "home#index"

  # get paths that don't match for router.js
  get "*path", to: "home#index", via: :all
end
