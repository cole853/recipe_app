class RecipesController < ApplicationController
  def recipeNames
    render json: { recipes: Recipe.limit(100).pluck(:name) }
  end
end
