Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get "/recipes/search", to: "recipes#search"
  get "/recipes/:id", to: "recipes#show"
  get "home/index"
  root "home#index"
end
