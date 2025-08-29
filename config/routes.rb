Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get "recipes/search", to: "recipes#search"
  # get "home/index"
  # root "home#index"
  #
  get "recipes/recipeNames"
  get "home/index"
  root "home#index"
end
