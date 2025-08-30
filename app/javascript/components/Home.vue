<template>
  <v-app style="background-color: #455A64">

    <!-- App bar -->
    <v-app-bar app color="#5EC7A1">
      <v-toolbar-title class="text-center" style="width: 100%">
        Recipe Search
      </v-toolbar-title>
      <v-btn class="custom-btn">Add Recipe</v-btn>
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
            placeholder="apples, oranges, grapes" 
            @keyup.enter="searchResults"
          />

          <!-- Search button -->
          <v-btn @click="searchResults" color="#5EC7A1">Search</v-btn>

          <!-- Results -->
          <v-infinite-scroll :height="300" class="mt-4 rounded-lg" color="#5EC7A1" :style="{backgroundColor: '#3e69b4'}">
              <template v-for="(recipe, index) in result" :key="recipe">
                <div :style="{backgroundColor: index % 2 === 0 ? '#5EC7A1' : 'white'}" class="pa-2 d-flex align-center justify-space-between">
                  {{ recipe }}
                  <v-btn class="custom-btn">view</v-btn>
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

  export default {
    setup() {
      const ingredients = ref('')
      const result = ref([])

      async function searchResults ({ done }) {
        if (!ingredients.value) return

        fetch(`/recipes/search?ingredients=${encodeURIComponent(ingredients.value)}`)
        .then(response => response.json())
        .then(data => {
          result.value = data.recipes
        }).catch(error => { console.error('Error:', error)})

        done("ok")
      }

      return {
        ingredients,
        result,
        searchResults
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