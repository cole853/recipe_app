class RecipesController < ApplicationController
  # def index
  #   render json: { recipes: Recipe.limit(100).pluck(:name) }
  # end

  def search
    ingreds = params[:ingredients].split(",").map { |ing| ing.strip }

    recipes = Recipe
    .joins(:ingredients)
    .where(ingredients: { name: ingreds })
    .group("recipes.id")
    .having("COUNT(DISTINCT ingredients.id) = ?", ingreds.size)
    .limit(100)
    .pluck(:name)

    render json: { recipes: recipes }
  end
end
