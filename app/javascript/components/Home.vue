<template>
  <v-app style="background-color: #455A64">

    <!-- App bar -->
    <v-app-bar app color="#5EC7A1">
      <v-app-bar-title class="text-center">
        Recipe Search
      </v-app-bar-title>
      <v-btn class="custom-btn mr-8">Add Recipe</v-btn>
    </v-app-bar>

    <!-- main body -->
    <v-main class="mt-8">
      <v-row class="justify-center">
        <v-col cols="12" sm="10" md="8" lg="6">

          <!-- Input box -->
          <v-text-field 
            clearable 
            variant="solo-filled"
            color="#5EC7A1"
            backgroundColor="white"
            label="enter ingredients separated by a comma"
            class="ingredient_input"
            v-model="ingredients" 
            placeholder="apples, oranges, grapes, . . ." 
            @keyup.enter="freshSearch"
          />

          <!-- Search button and result number display-->
          <div class="d-flex align-center justify-space-between">
          <v-btn @click="freshSearch" class="custom-btn" color="#5EC7A1">Search</v-btn>
          <v-card variant="default" :text="resultCount" style="font-size: 25px"/>
          </div>

          <!-- Results -->
          <v-infinite-scroll ref="infiniteScrollRef" :height="300" @load="load" class="mt-3 rounded-lg" color="#5EC7A1" :style="{backgroundColor: '#536c77'}">
              <template v-for="(recipe, index) in recipes" :key="recipe">
                <div :style="{backgroundColor: index % 2 === 0 ? '#5EC7A1' : 'white'}" class="pa-2 d-flex align-center justify-space-between">
                  {{ recipe[1] }}
                  <v-btn :to="'/recipe/' + recipe[0]" class="custom-btn">view</v-btn>
                </div>
              </template>
          </v-infinite-scroll>

        </v-col>
      </v-row>
    </v-main>
  </v-app>
</template>

<script>
import { ref } from 'vue'
import axios from 'axios'

  export default {
    setup() {
      const recipes = ref([])
      const currentPage = ref(1)
      const hasMore = ref(true)
      const ingredients = ref('')
      const resultCount = ref('-- Recipes Found')
      const infiniteScrollRef = ref(null)

      async function freshSearch() {
        recipes.value = []
        currentPage.value = 1
        hasMore.value = true

        infiniteScrollRef.value.reset()

        await load
      }
      
      async function load ({ done } = {}) {
        if (ingredients.value.length === 0 || !hasMore) {
          done?.('empty')
          return
        }
        try {
          const response = await axios.get('/recipes/search', {
            params: {
              ingredients: ingredients.value,
              page: currentPage.value
            }
          });

          console.log(response.data.recipes)

          if (response.data.recipes.length === 0) {
            done?.('empty')
            resultCount.value = "" + 0 + " Recipes Found"
            return
          }

          recipes.value = recipes.value.concat(response.data.recipes);
          hasMore.value = response.data.has_next;
          resultCount.value = "" + response.data.result_count + " Recipes Found"
          currentPage.value++;

          if (!response.data.has_next) {
            done?.('empty')
            return
          }
          else {
            done?.('ok')
          }

        } catch (error) {
          console.error('Error Loading Recipes:', error)
          done('error')
        }
      }

      return {
        recipes,
        ingredients,
        resultCount,
        infiniteScrollRef,
        load,
        freshSearch
      }
    }
  }
</script>


<style>
.custom-btn {
  background-color: #b43e69 !important;
  color: black !important;
}
.custom-infinite-scroll {
  background-color: "#5EC7A1" !important;
  color: "#5EC7A1" !important;
}
</style>