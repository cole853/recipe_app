class RecipesController < ApplicationController
  def show
    @recipe = Recipe.find(params[:id])

    render json: {
      name: @recipe.name,
      amounts: @recipe.amounts,
      instructions: @recipe.instructions,
      link: @recipe.link
    }
  end

  def search
    if params[:ingredients].size() == 0
      render json: {
        recipes: "",
        has_next: false,
        result_count: 0
      }
      return
    end
    ingreds = params[:ingredients].split(",").map { |ing| ing.strip }
    page = params[:page] || 1

    recipes = Recipe
    .joins(:ingredients)
    .where(ingredients: { name: ingreds })
    .group("recipes.id")
    .having("COUNT(DISTINCT ingredients.id) = ?", ingreds.size)
    .page(page)

    render json: {
      recipes: recipes.pluck(:id, :name),
      has_next: recipes.next_page.present?,
      result_count: recipes.total_count
    }
  end
end
