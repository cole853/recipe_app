require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "no strawberry butter for ham spinach mozzarella" do
    get "/recipes/search", params: { ingredients: "ham,spinach,mozzarella cheese" }

    assert_response :success
    json_response = JSON.parse(response.body)

    # return ham and spinach quiche
    assert_includes json_response["recipes"], "Ham and Spinach Quiche"

    # don't return strawberry butter
    assert_not_includes json_response["recipes"], "Strawberry Butter"
  end

  test "should not return recipe with fewer ingredients but all match" do
    get "/recipes/search", params: { ingredients: "eggs,spinach,milk" }

    assert_response :success
    json_response = JSON.parse(response.body)

    # return ham and spinach quiche
    assert_includes json_response["recipes"], "Ham and Spinach Quiche"

    # don't return omelette
    assert_not_includes json_response["recipes"], "Omelette"
  end

  test "should return recipe with more ingredients and all match" do
    get "/recipes/search", params: { ingredients: "eggs,vanilla" }

    assert_response :success
    json_response = JSON.parse(response.body)

    # return sugar cookies
    assert_includes json_response["recipes"], "Sugar Cookies"
  end

  test "should not return recipe with fewer ingredients that dont match" do
    get "/recipes/search", params: { ingredients: "flour,sugar,butter,vanilla" }

    assert_response :success
    json_response = JSON.parse(response.body)

    # return sugar cookies
    assert_includes json_response["recipes"], "Sugar Cookies"

    # don't return omelette
    assert_not_includes json_response["recipes"], "Omelette"
  end

  test "should not return recipe with more ingredients that don't match" do
    get "/recipes/search", params: { ingredients: "butter,eggs" }

    assert_response :success
    json_response = JSON.parse(response.body)

    # don't return caprese salad
    assert_not_includes json_response["recipes"], "Caprese Salad"
  end
end
