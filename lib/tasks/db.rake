namespace :db do
  desc "Load recipes from recipes_data.csv"
  task load_recipes: :environment do
    require "csv"

    # function to reformat strings coming from the csv file
    def format_string(str)
      str = str[2..-3]
      str.gsub("\", \"", "\n")
    end

    csv_path = "recipes_data.csv"

    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    total_recipe_count = 0

    # divide the csv into 1k row slices
    CSV.foreach(csv_path, headers: true).each_slice(1_000) do |rows|
      recipe_count = 0

      # arrays to hold values that will be inserted
      add_ingredients = Array.new
      add_recipe_ingredients = Array.new
      add_recipes = Array.new
      recipe_to_ingredient = Array.new

      # each row
      rows.each do |row|
        # add the recipe
        add_recipes.push({
          name: row["title"],
          amounts: format_string(row["ingredients"]),
          instructions: format_string(row["directions"]),
          link: row["link"]&.presence
        })

        # make an array of ingredients
        ingredient_str = format_string row["NER"]
        ingredient_array = ingredient_str.split("\n")

        # iterate through ingredients
        for ingred in ingredient_array
          add_ingredients.push({ name: ingred }) # add them to the list of ingredients that will be added to the db
          recipe_to_ingredient.push({ recipe_num: recipe_count, ingredient: ingred }) # add a hash with recipe_count and ingredient to add to RecipeIngredient later
        end

        recipe_count += 1
        total_recipe_count += 1
      end

      # insert the new recipes
      recipe_ids = Recipe.insert_all(add_recipes, returning: [ :id ]).pluck("id")

      # insert all ingredients while skipping duplicates. Then get a hash of ingredient names to their id.
      Ingredient.upsert_all(add_ingredients.uniq, unique_by: :name)
      ingredient_to_id = Ingredient.where(name: add_ingredients.map { |ingred| ingred[:name] }).pluck(:name, :id).to_h

      # use recipe_to_ingredient to make hashes for RecipeIngredient and insert
      for ri in recipe_to_ingredient
        add_recipe_ingredients.push({ recipe_id: recipe_ids[ri[:recipe_num]], ingredient_id: ingredient_to_id[ri[:ingredient]] })
      end
      RecipeIngredient.insert_all(add_recipe_ingredients)

      # print the time and how many recipes were entered
      end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      puts "-----------------------------\nExecution time: #{(end_time - start_time).round(2)} seconds\nRecipes entered: #{total_recipe_count}"
    end
  end
end
