require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  fixtures :all

  ######################################################## SEARCH TESTS ########################################################
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

  ######################################################## SHOW TEST ########################################################
  test "show should return correct values" do
    idNum = Recipe.where(name: "Chocolate Cake").pluck(:id)

    # make sure values are correct
    showTest(idNum, {
      name: "Chocolate Cake",
      amounts: "2 cups flour\n1 cup sugar\n3 eggs\n1/2 cup butter\n1 cup milk",
      instructions: "1. Mix dry ingredients\n2. Add wet ingredients\n3. Bake at 350°F for 30 minutes",
      link: "https://example.com/chocolate-cake",
      ingredients: [ "sugar", "eggs", "milk", "butter", "flour" ]
    })
  end

  ######################################################## DESTROY TEST ########################################################
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

  ######################################################## UPDATE TESTS ########################################################
  test "update should change values" do
    updateTest({}, {
      name: "testName",
      amounts: "1 pound dry noodles\n4 quarts water",
      instructions: "bring water to a boil\nadd noodles to boiling water",
      link: "testLink",
      ingredients: [ "ingreda", "ingredb", "ingredc" ]
    },
    true)

    # make sure unused vanilla ingredient is deleted
    ingredient_names = Ingredient.all.pluck(:name)
    assert_not_includes ingredient_names, "vanilla"
  end

  test "strings should be stripped" do
    updateTest({ name: "  testName  " }, {
      name: "testName",
      amounts: "1 pound dry noodles\n4 quarts water",
      instructions: "bring water to a boil\nadd noodles to boiling water",
      link: "testLink",
      ingredients: [ "ingreda", "ingredb", "ingredc" ]
    },
    true)

    # make sure unused vanilla ingredient is deleted
    ingredient_names = Ingredient.all.pluck(:name)
    assert_not_includes ingredient_names, "vanilla"
  end

  test "update with empty link should work" do
    updateTest({ link: "" }, {
      name: "testName",
      amounts: "1 pound dry noodles\n4 quarts water",
      instructions: "bring water to a boil\nadd noodles to boiling water",
      link: "",
      ingredients: [ "ingreda", "ingredb", "ingredc" ]
    },
    true)
  end

  test "empty name should not update" do
    updateTest({ name: "  " }, {})
  end

  test "empty instructions should not update" do
    updateTest({ instructions: " " }, {})
  end

  test "empty amounts should not update" do
    updateTest({ amounts: "" }, {})
  end

  test "ingredients string should not update" do
    updateTest({ ingredients: "ingreda, ingredb, ingredc" }, {})
  end

  test "empty ingredients should not update" do
    updateTest({ ingredients: [ " " ] }, {})
  end

  test "empty ingredients should be ignored" do
    updateTest({ ingredients: [ " ", "eggs", "beets" ] }, {
      name: "testName",
      amounts: "1 pound dry noodles\n4 quarts water",
      instructions: "bring water to a boil\nadd noodles to boiling water",
      link: "testLink",
      ingredients: [ "eggs", "beets" ]
    }, true)
  end

  ######################################################## PRIVATE FUNCTIONS ########################################################
  private
  def ingredientSearch(ingredients)
    get "/recipes/search", params: { ingredients: ingredients }

    assert_response :success
    json_response = JSON.parse(response.body)

    # get a list of recipe names
    json_response["recipes"].map { |x| x[1] }
  end

  def showTest(idNum, expected)
    # get the recipe to check values
    get "/recipes/#{idNum[0]}"

    assert_response :success
    json_response = JSON.parse(response.body)

    # make sure ingredient information is right
    assert_equal expected[:name], json_response["name"]
    assert_equal expected[:amounts].strip, json_response["amounts"].strip
    assert_equal expected[:instructions].strip, json_response["instructions"].strip
    assert_equal expected[:link], json_response["link"]
    assert_equal expected[:ingredients], json_response["ingredients"]
  end

  def updateTest(input, output, shouldWork = false)
    # change default chnges according to input
    changes = update_hash({
      name: "testName",
      ingredients: [ "ingreda", "ingredb", "ingredc" ],
      instructions: "bring water to a boil\nadd noodles to boiling water",
      amounts: "1 pound dry noodles\n4 quarts water",
      link: "testLink"
    },
    input)

    # change default expected according to output
    expected = update_hash({
      name: "Sugar Cookies",
      amounts: "2 1/2 cups flour\n1 cup sugar\n1 cup butter\n2 eggs\n1 tsp vanilla",
      instructions: "1. Cream butter and sugar\n2. Add eggs and vanilla\n3. Mix in flour\n4. Bake at 375°F for 8-10 minutes",
      link: "https://example.com/sugar-cookies",
      ingredients: [ "butter", "flour", "eggs", "sugar", "vanilla" ]
    },
    output)

    # try to change the recipe
    idNum = Recipe.where(name: "Sugar Cookies").pluck(:id)
    patch "/recipes/#{idNum[0]}", params: changes

    # make sure the proper result was returned
    if shouldWork
      assert_response :success
    else
      assert_response :unprocessable_content
    end

    # check that recipe values are as expected
    showTest(idNum, expected)
  end

  # update the matching keys of an old hash to new values
  def update_hash(old, new)
    shared_keys = old.keys & new.keys
    old.merge(new.slice(*shared_keys))
  end
end
