class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[ show destroy ]

  # return a page of ids and names for recipes that include all of the ingredients in params
  # also returns the number of results for the search and whether there is another page to load
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

  # return the recipe's information
  def show
    render json: {
      name: @recipe.name,
      amounts: @recipe.amounts,
      instructions: @recipe.instructions,
      link: @recipe.link
    }
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  # delete a recipe and any of its ingredients that are no longer used in a recipe
  def destroy
    ActiveRecord::Base.transaction do
      ingredient_ids = @recipe.ingredients.pluck(:id)
      @recipe.destroy

      ingreds = Ingredient
      .where(id: ingredient_ids)
      .left_joins(:recipes)
      .group("ingredients.id")
      .having("COUNT(recipes.id) = 0")

      ingreds.destroy_all
    end
  end

  private
  def set_recipe
    @recipe = Recipe.find(params[:id])
  end
end
