<template>
  <div>
    <h1>{{ message }}</h1>
    <button @click="fetchRecipes">Get Recipes</button>

    <div v-if="recipes.length > 0">
      <p v-for="recipe in recipes" :key="recipe">
        {{ recipe }}
      </p>
    </div>
  </div>
</template>
<script>
  export default {
    data() {
      return {
        message: 'Hello, Vue!',
        recipes: []
      }
    },
    methods: {
      fetchRecipes() {
        fetch('/recipes/recipeNames').then(response => response.json()).then(data => {this.recipes = data.recipes})
      }
    }
  }
</script>
<style>
  h1 {
    color: blue;
  }
</style>