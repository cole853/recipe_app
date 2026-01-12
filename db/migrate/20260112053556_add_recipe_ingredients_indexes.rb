class AddRecipeIngredientsIndexes < ActiveRecord::Migration[8.0]
  def change
    unless index_exists?(:recipe_ingredients, :recipe_id)
      add_index :recipe_ingredients, :recipe_id
    end
    
    unless index_exists?(:recipe_ingredients, :ingredient_id)
      add_index :recipe_ingredients, :ingredient_id
    end
    
    unless index_exists?(:recipe_ingredients, [:ingredient_id, :recipe_id])
      add_index :recipe_ingredients, [:ingredient_id, :recipe_id]
    end
    
    unless index_exists?(:recipes, :created_at)
      add_index :recipes, :created_at
    end
  end
end
