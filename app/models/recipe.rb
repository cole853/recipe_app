class Recipe < ApplicationRecord
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  validates :name, presence: true
  validates :instructions, presence: true
  validates :amounts, presence: true

  # change the ingredients for a recipe
  def update_ingredients=(ingredients)
    # remove all recipe_ingredients
    self.recipe_ingredients.destroy_all

    # format each ingredient and add it to add_ingredients
    add_ingredients = []
    for ingredient in ingredients do
      next if ingredient.blank?

      add_ingredients.push({ name: ingredient.downcase.strip })
    end

    # add any new ingredients then make a map of ingredient names to id
    Ingredient.upsert_all(add_ingredients.uniq, unique_by: :name)
    ingredient_to_id = Ingredient.where(name: add_ingredients.map { |ingred| ingred[:name] }).pluck(:name, :id).to_h

    # make an array with hashes connecting recipe id to ingredient ids then insert new recipe_ingredients
    add_recipe_ingredients = []
    for ri in add_ingredients
      add_recipe_ingredients.push({ recipe_id: self.id, ingredient_id: ingredient_to_id[ri[:name]] })
    end
    RecipeIngredient.insert_all(add_recipe_ingredients)
  end
end
