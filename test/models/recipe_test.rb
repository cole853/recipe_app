require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  test "should not save recipe without name" do
    recipe = Recipe.new
    recipe.instructions = "testing testing"
    assert_not recipe.save, "Saved recipe without a name"
  end

  test "should not save recipe without instructions" do
    recipe = Recipe.new
    recipe.name = "test name"
    assert_not recipe.save, "Saved recipe without instructions"
  end
end
