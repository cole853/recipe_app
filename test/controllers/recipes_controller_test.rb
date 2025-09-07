require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "no strawberry butter for ham spinach mozzarella" do
    recipes = ingredientSearch("ham,spinach,mozzarella cheese")

    # return ham and spinach quiche
    assert_includes recipes, "Ham and Spinach Quiche"
    # don't return strawberry butter
    assert_not_includes recipes, "Strawberry Butter"
  end

  test "should not return recipe with fewer ingredients but all match" do
    recipes = ingredientSearch("eggs,spinach,milk")

    # return ham and spinach quiche
    assert_includes recipes, "Ham and Spinach Quiche"
    # don't return omelette
    assert_not_includes recipes, "Omelette"
  end

  test "should return recipe with more ingredients and all match" do
    recipes = ingredientSearch("eggs,vanilla")

    # return sugar cookies
    assert_includes recipes, "Sugar Cookies"
  end

  test "should not return recipe with fewer ingredients that dont match" do
    recipes = ingredientSearch("flour,sugar,butter,vanilla")

    # return sugar cookies
    assert_includes recipes, "Sugar Cookies"
    # don't return omelette
    assert_not_includes recipes, "Omelette"
  end

  test "should not return recipe with more ingredients that don't match" do
    recipes = ingredientSearch("butter,eggs")

    # don't return caprese salad
    assert_not_includes recipes, "Caprese Salad"
  end

  test "show should return correct values" do
    idNum = Recipe.where(name: "Chocolate Cake").pluck(:id)
    get "/recipes/#{idNum[0]}"

    assert_response :success
    json_response = JSON.parse(response.body)

    # make sure ingredient information is right
    assert_equal json_response["name"], "Chocolate Cake"
    assert_equal json_response["amounts"].strip, "2 cups flour\n1 cup sugar\n3 eggs\n1/2 cup butter\n1 cup milk".strip
    assert_equal json_response["instructions"].strip, "1. Mix dry ingredients\n2. Add wet ingredients\n3. Bake at 350°F for 30 minutes".strip
    assert_equal json_response["link"], "https://example.com/chocolate-cake"
  end

  test "destroy should remove recipe and unused ingredients" do
    idNum = Recipe.where(name: "Caprese Salad").pluck(:id)
    delete "/recipes/#{idNum[0]}"

    recipe_names = Recipe.all.pluck(:name)
    ingredient_names = Ingredient.all.pluck(:name)

    # make sure recipe and unused ingredients are gone
    assert_not_includes recipe_names, "Caprese Salad"
    assert_not_includes ingredient_names, "tomato"
    assert_not_includes ingredient_names, "basil"
    assert_not_includes ingredient_names, "olive oil"

    # make sure used ingredient in recipe was not deleted
    assert_includes ingredient_names, "mozzarella cheese"
  end

  private
  def ingredientSearch(ingredients)
    get "/recipes/search", params: { ingredients: ingredients }

    assert_response :success
    json_response = JSON.parse(response.body)

    # get a list of recipe names
    json_response["recipes"].map { |x| x[1] }
  end
end
