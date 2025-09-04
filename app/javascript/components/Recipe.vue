<template>
  <v-app style="background-color: #455A64">

    <!-- App bar -->
    <v-app-bar app color="#5EC7A1">
      <v-btn :to="'/'" class="custom-btn ml-2" style="position: absolute; left: 16px;">back</v-btn>
      <v-app-bar-title class="text-center">
        {{ name }}
      </v-app-bar-title>
      <div style="position: absolute; right: 16px;">
        <v-btn class="custom-btn mr-2">edit</v-btn>
        <v-btn class="custom-btn mr-2">delete</v-btn>
      </div>
    </v-app-bar>
  
    <!-- main body -->
    <v-main>
      <v-row class="justify-center">
        <v-col cols="12" sm="10" md="8" lg="6">

          <!-- card for recipe -->
          <v-card class="mt-8 rounded-lg" :style="{ border: '2px solid #b43e69' }">
            <v-card-item style="background-color: #b43e69">
              <div class="pa-2 d-flex align-center flex-wrap">
                <v-card-title class="text-h4" style="flex: 1; min-width: 200px;">{{ name }}</v-card-title>
                <v-btn :href="'http://' + link" target="_blank" rounded="xl" color="#5EC7A1">recipe source</v-btn>
              </div>
            </v-card-item>
            <v-card-item>
              <v-card-title>Ingredients</v-card-title>
              <v-card-text style="white-space: pre-line;">{{ amounts }}</v-card-text>
            </v-card-item>
            <v-divider/>
            <v-card-item>
              <v-card-title>Directions</v-card-title>
              <v-card-text style="white-space: pre-line;">{{ instructions }}</v-card-text>
            </v-card-item>
            <v-card-item class="pa-0" style="background-color: #b43e69">
              <v-card-text class="text-caption pa-1">{{ link }}</v-card-text>
            </v-card-item>
          </v-card>
          
        </v-col>
      </v-row>
    </v-main>
  </v-app>
</template>

<script>
import { ref, onMounted, watch } from 'vue'
import axios from 'axios'

export default {
  props: {
    id: String,
    required: true
  },
  setup (props) {
    const name = ref('')
    const amounts = ref('')
    const instructions = ref('')
    const link = ref('')

    // gets the recipe information and sets values
    async function getRecipe() {
      try {
        const response = await axios.get('/recipes/' + props.id);
        name.value = response.data.name
        amounts.value = response.data.amounts
        instructions.value = response.data.instructions.replace("\\u00b0", "\u00b0")
        link.value = response.data.link
        console.log(amounts.value)

      } catch (error) {
        console.error('Error Showing Recipe:', error)
      }
    }

    onMounted(getRecipe)
    watch(() => props.id, getRecipe)

    return {
      name,
      amounts,
      instructions,
      link
    }
  }
}
</script>