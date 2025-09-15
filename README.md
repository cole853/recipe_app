# Versions and Setup

## Versions

* vite_ruby: 3.9.2
* vite_rails: 3.0.19
* rails: 8.0.2
* ruby: ruby 3.2.3 (2024-01-18 revision 52bb2ac0a6) [x86_64-linux-gnu]
* node: v22.18.0
* yarn: 1.22.22

installed packages:

recipe_app@ /recipe_app

├─┬ @vitejs/plugin-vue@6.0.1

│ └── vite@5.4.19 deduped

├─┬ vite-plugin-ruby@5.1.1

│ └── vite@5.4.19 deduped

└── vite@5.4.19

* Linux Mint 22.2 Cinnamon
* Firefox 142.0.1 (64-bit)
* 1920p x 1080p monitor


## Setup

Installing necessary tools
```
sudo apt update
sudo apt install rbenv
curl -o-  https://raw.githubusercontent.com/nvm-sh/v0.39.0/install.sh | bash
sudo apt install npm
sudo npm install -g yarn
```

clone and setup
```
git clone https://github.com/cole853/recipe_app.git
cd recipe_app
sudo apt install ruby-bundler
bundle install
yarn install
```

download the recipes_data.csv file from [here](https://www.kaggle.com/datasets/wilmerarltstrmberg/recipe-dataset-over-2m/data)
extract the file and move it to the recipe_app directory

add recipes to database (took about 25 minutes on my pc)
```
rake db:migrate
rake db:load_recipes
```

start project
```
rails server
```

open http://localhost:3000 in a browser

# Vue Components

## App.vue

The App.vue component is the root component for the project.


## Home.vue

The Home.vue component contains a text input where the user can enter recipe ingredients separated by commas. When the "search" button is clicked or enter is pressed on the keyboard, recipes that use all of the entered ingredients are displayed in the infinite scroll component below. Each of these recipes can be viewed by pressing the corresponding "view" button (Recipe.vue). The home component also has an "add recipe" button in the top right corner that allows the user to create a new recipe (Create.vue).


## Recipe.vue

The Recipe.vue component is where the user can read an individual recipe. The recipe name, ingredient amounts, and directions are shown along with the link to the original recipe. On the top right of the recipe card, there is a "recipe source" button. Clicking this button will open a new tab with the source for the recipe.

The app bar at the top of the Recipe.vue component has three buttons. The "back" button in the top left corner will take the user back to the Home.vue component. The "delete" button in the top right corner will open a dialog asking the user whether they want to delete the recipe. Pressing delete on this dialog will delete the recipe and take the user back to the Home.vue component. Cancel will close the dialog and leave the user on the Recipe.vue component. The "edit" button next to the "delete" button allows the user to change the recipe. Pressing edit brings up an overlay with the RecipeEdit.vue component, where recipe values can be modified.


## Create.vue

The Create.vue component makes it possible for the user to create a new recipe. The app bar in this component has a back button in the top left corner that brings the user back to the Home.vue component. Create.vue uses the same RecipeEdit.vue component that is used to edit recipes.


## RecipeEdit.vue

RecipeEdit.vue is used by Create.vue and Recipe.vue. This component has text fields for recipe name, ingredient amounts, search ingredients, directions, and link. Ingredient amounts let the user know how much of an ingredient is used in the recipe while search ingredients are used to search for recipes in the Home.vue component. For example, ingredient amount might be "3 1/2 c. flour" while the search ingredient would be "flour". Directions let the user know how to make the dish, including cook times and temperatures. The link can be added if a recipe was found on a website. The link is the only field that can be left blank when creating or editing a recipe.

RecipeEdit.vue has two buttons in the bottom right corner. The "cancel" button takes the user back to Home.vue when creating a new recipe or returns the user to Recipe.vue when editing a recipe. Pressing ok will save changes and show the new or edited recipe in Recipe.vue.


# Rails

## Database

The database contains a Recipe model and an Ingredient model these are connected with a many-to-many relationship through a RecipeIngredient model. More information about what each model contains can be found in db/migrate/schema.rb

An SQLite database was used for this project because it was easy to set up, and only a small database with low traffic was needed. If a larger database with more traffic was needed, a different database like PostgreSQL might have been a better option.


## Controllers

The HomeController is used to start the Vue app.

The RecipeController is used to get information from and update the database when needed. This controller includes several functions:
* search: sends a page of recipes with all of the ingredients that were put into the search
* show: sends all of the information for a recipe when given its ID number
* create: creates a new recipe
* update: updates a recipe
* destroy: removes a recipe from the database

Other functions are used by the above functions, like ingredient_check, remove_unused_ingreds, and update_ingredients (in app/models/recipe.rb). ingredient_check is used to make sure ingredients are in the proper form and that there is at least one ingredient when recipes are created or updated. When a recipe is edited or deleted, remove_unused_ingreds checks each of the previously used ingredients. If an ingredient is no longer used by any recipe, it is destroyed. update_ingredients adds new ingredients when a recipe is edited or created.

Tests for the main functions can be found in test/controllers/recipes_controller_test.rb


# Things I Would Do Differently

## Smaller Commits

While working on this project, I tried to push frequent updates to GitHub. However, there were a few commits that should have been divided into multiple commits. One example is when I completed the edit capabilities of the app. In one commit, I added the new Vue component RecipeEdit.vue, the edit function (and other functions it used), and tests for the function. If I did this again, I would definitely make a separate commit for the RecipeEdit.vue component and possibly make separate commits for the edit function and its tests. This would turn my one commit into two or three, meaning a lot less work would be lost if an issue occurred.


## Complete The Backend Before Adding Vue Components

I hadn't used Vue or Rails before this project. It might have been easier to learn these tools by focusing on one before starting the other. During this project, I went back and forth between adding components in Vue and adding functions in Rails. If I did a project like this again, I would finish the backend functions before starting on Vue components. Tests could be used to make sure the functions work correctly before adding Vue components.


## Learn More about HTML and Vuetify Before Adding Vue Components

There were several times during this project that I had problems getting Vue components to look how I wanted. While I did eventually get components to look right, I think the process would have been a lot easier if I had spent more time learning the basics of HTML and Vuetify components.


# Possible Improvements

## Limit Recipes in Home.vue

When a search is made in the Home.vue component recipes are loaded 25 at a time, which prevents many recipes from causing performance issues. However, a user who searches for a commonly used ingredient could continue to load 25 recipes at a time until a very large number of recipes is displayed, which could cause performance issues. In order to fix this, there should be a limit on how many pages can be loaded at a time. For example, if a maximum of 5 pages (125 recipes) could be loaded at a time, when the user scrolls to the 6th page, the first page would be forgotten, and the 6th page would be loaded. Then, if the user scrolls back up to the first page, it would be reloaded, and the 6th page would be forgotten.


## Add User Profiles

Currently, any user can add, remove, edit, and view any recipe they want to. It would be better if users could only remove and edit their own recipes while having access to view any recipe. Users could also have a favorite recipes list to keep track of recipes they like.


## More Scalable Database

As mentioned earlier, SQLite was used in this project because of how easy it is to set up. If this app used a larger amount of data or had to handle more traffic, a different database like PostgreSQL might be a better choice.


# Helpful Websites

* [rubyonrails tutorial](https://guides.rubyonrails.org/getting_started.html#rails-routes)

* [recipe data](https://www.kaggle.com/datasets/wilmerarltstrmberg/recipe-dataset-over-2m/data)

* [Building a Rails App with a Vue Frontend](https://clouddevs.com/ruby-on-rails/building-app-with-vuejs-frontend/)

* [vue tutorial](https://vuejs.org/tutorial/#step-1)

* [Integrating Vite and Vue with Rails 7](https://engineering.terakeet.com/posts/integrating-vite-and-vue-with-rails-7/)

* [vuetify components](https://vuetifyjs.com/en/components/all/)

* [SQLite vs PostgreSQL: A Detailed Comparison](https://www.datacamp.com/blog/sqlite-vs-postgresql-detailed-comparison)
