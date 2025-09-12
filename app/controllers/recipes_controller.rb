class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[ show destroy update]

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
      link: @recipe.link,
      ingredients: @recipe.ingredients.pluck(:name)
    }
  end

  # create a new recipe
  def create
    ActiveRecord::Base.transaction do
      permittedParams = recipe_params
      @recipe = Recipe.new(permittedParams.except(:ingredients))

      if ingredient_check && @recipe.save
        @recipe.update_ingredients = permittedParams[:ingredients]
        render json: @recipe, status: :created
      else
        render json: { errors: @recipe.errors.full_messages }, status: :unprocessable_content
        raise ActiveRecord::Rollback
      end
    end
  end

  # update the recipe
  def update
    ActiveRecord::Base.transaction do
      ingredient_ids = @recipe.ingredients.pluck(:id)
      permittedParams = recipe_params
      if ingredient_check && @recipe.update(permittedParams.except(:ingredients))
        @recipe.update_ingredients = permittedParams[:ingredients]
        remove_unused_ingreds(ingredient_ids)
        render json: @recipe, status: :ok
      else
        render json: { errors: @recipe.errors.full_messages }, status: :unprocessable_content
        raise ActiveRecord::Rollback
      end
    end
  end

  # delete a recipe and any of its ingredients that are no longer used in a recipe
  def destroy
    ActiveRecord::Base.transaction do
      ingredient_ids = @recipe.ingredients.pluck(:id)
      @recipe.destroy
      remove_unused_ingreds(ingredient_ids)
    end
  end

  private
  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.permit(:name, :instructions, :amounts, :link, ingredients: [])

    {
      name: params[:name].strip,
      instructions: params[:instructions].strip,
      amounts: params[:amounts].strip,
      link: params[:link].strip,
      ingredients: params[:ingredients]
    }
  end

  # make sure ingredients are valid
  def ingredient_check
    if !params[:ingredients].is_a?(Array) || params[:ingredients].empty?
      return false
    end

    for ingred in params[:ingredients]
      if !ingred.blank?
        return true
      end
    end

    false
  end

  # remove ingredients that are no longer used after delete or update
  def remove_unused_ingreds(ingredient_ids)
    ingreds = Ingredient
      .where(id: ingredient_ids)
      .left_joins(:recipes)
      .group("ingredients.id")
      .having("COUNT(recipes.id) = 0")

      ingreds.destroy_all
  end
end
