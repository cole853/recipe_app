<template>
  <h1>Recipe Search</h1>
  <p>enter ingredients separated by a comma</p>
  <input 
    v-model="ingredients" 
    class="ingredient-input" 
    placeholder="enter ingredients" 
    @keyup.enter="searchResults"
  />
  <v-btn @click="searchResults">Search</v-btn>

  <div v-if="result.length > 0">
    <p v-for="recipe in result" :key="recipe">
      {{ recipe }}
    </p>
  </div>
</template>

<script>
import { ref } from 'vue'

  export default {
    setup() {
      const ingredients = ref('')
      const result = ref([])

      const searchResults = () => {
        if (!ingredients.value) return

        fetch(`/recipes/search?ingredients=${encodeURIComponent(ingredients.value)}`)
        .then(response => response.json())
        .then(data => {
          result.value = data.recipes
        }).catch(error => { console.error('Error:', error)})
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
  h1 {
    color: blue;
  }
</style>