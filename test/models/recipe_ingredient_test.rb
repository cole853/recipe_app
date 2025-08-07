require "test_helper"

class RecipeIngredientTest < ActiveSupport::TestCase
  test "should not save recipe ingredient without amount" do
    ri = RecipeIngredient.new
    ri.recipe_id = 1
    ri.ingredient_id = 1
    assert_not ri.save, "Saved recipe ingredient without amount"
  end
end
