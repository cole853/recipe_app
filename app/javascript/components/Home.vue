<template>
  <v-app style="background-color: #455A64">

    <!-- App bar -->
    <v-app-bar app color="#5EC7A1">
      <v-app-bar-title class="text-center">
        Recipe Search
      </v-app-bar-title>
      
      <v-btn class="custom-btn" style="position: absolute; right: 16px;">Add Recipe</v-btn>
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
          <v-btn @click="freshSearch" class="custom-btn">Search</v-btn>
          <v-card variant="default" :text="resultCount" style="font-size: 25px"/>
          </div>

          <!-- Results -->
          <v-infinite-scroll ref="infiniteScrollRef" :height="300" @load="loadRecipes" class="mt-3 rounded-lg" color="#5EC7A1" :style="{ backgroundColor: '#536c77', border: '2px solid #b43e69' }">
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
import { ref, onMounted, onBeforeUnmount } from 'vue'
import axios from 'axios'

  export default {
    setup() {
      const recipes = ref([])
      const currentPage = ref(1)
      const hasMore = ref(true)
      const ingredients = ref('')
      const resultCount = ref('-- Recipes Found')
      const infiniteScrollRef = ref(null)

      // resets values from previous search then calls the loadRecipes function
      async function freshSearch() {
        recipes.value = []
        currentPage.value = 1
        hasMore.value = true

        if (infiniteScrollRef.value) {
          infiniteScrollRef.value.reset()
        }

        await loadRecipes()
      }
      
      // load function for the infinite scroll component
      // loads the next page of recipes
      async function loadRecipes ({ done } = {}) {
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

          if (response.data.recipes.length === 0) {
            done?.('empty')
            resultCount.value = "0 Recipes Found"
            return
          }

          const nFormat = new Intl.NumberFormat(undefined);
          recipes.value = recipes.value.concat(response.data.recipes);
          hasMore.value = response.data.has_next;
          resultCount.value = `${nFormat.format(response.data.result_count)} Recipes Found`
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

      async function saveState() {
        localStorage.setItem('searchState', JSON.stringify({
          recipes: recipes.value,
          ingredients: ingredients.value,
          resultCount: resultCount.value,
          hasMore: hasMore.value,
          currentPage: currentPage.value,
          infiniteScrollPos: infiniteScrollRef.value.$el.scrollTop
        }))
      }

      async function loadState() {
        const saved = localStorage.getItem('searchState')
        if(saved) {
          const state = JSON.parse(saved)
          recipes.value = state.recipes
          ingredients.value = state.ingredients
          resultCount.value = state.resultCount
          hasMore.value = state.hasMore
          currentPage.value = state.currentPage
          infiniteScrollRef.value.$el.scrollTop = state.infiniteScrollPos
        }
      }

      onMounted(loadState)
      onBeforeUnmount(saveState)

      return {
        recipes,
        ingredients,
        resultCount,
        infiniteScrollRef,
        loadRecipes,
        freshSearch
      }
    }
  }
</script>


<style>
.custom-btn {
  background-color: #b43e69 !important;
  color: black !important;
  border-radius: 24px !important;
}
.custom-infinite-scroll {
  background-color: "#5EC7A1" !important;
  color: "#5EC7A1" !important;
}
</style>