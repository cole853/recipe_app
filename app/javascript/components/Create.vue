<template>
  <v-app style="background-color: #455A64">

    <!-- unsuccessful save snackbar -->
    <v-snackbar v-model="snackbar" :timeout= "sbtimeout">
      {{ sbText }}

      <template v-slot:actions>
        <v-btn
          color="#b43e69"
          variant="text"
          @click="snackbar = false"
        >
          Close
        </v-btn>
      </template>
    </v-snackbar>

    <!-- loading overlay -->
    <v-overlay :model-value="isLoading" class="align-center justify-center">
    <v-card class="pa-4 text-center">
      <v-progress-circular indeterminate size="64"/>
      <div class="mt-4">Loading recipe...</div>
    </v-card>
    </v-overlay>

    <!-- App bar -->
    <v-app-bar app color="#5EC7A1">
      <v-btn :to="'/'" class="custom-btn ml-2" style="position: absolute; left: 16px;">back</v-btn>
      <v-app-bar-title class="text-center">
        Recipe Create
      </v-app-bar-title>
    </v-app-bar>

    <v-main class="mt-8">
      <v-row class="justify-center">
        <v-col cols="12" sm="10" md="8" lg="6" class="pa-0">
          <v-card style="background-color: #455A64" class="mx-auto d-flex rounded-lg" :style="{ border: '3px solid #b43e69' }">
            <RecipeEdit @cancel="cancel" @save="save"/>
          </v-card>
        </v-col>
      </v-row>
    </v-main>
    
  </v-app>
</template>

<script>
import RecipeEdit from './RecipeEdit.vue'
import { useRouter } from 'vue-router'
import { ref } from 'vue'
import axios from 'axios'

export default {
  components: {
    RecipeEdit
  },
  setup() {
    const isLoading = ref(false)

    const router = useRouter()

    const snackbar = ref(false)
    const sbText = ref("Save was unsuccessful\nonly the link can be left blank")
    const sbtimeout = ref(3000)

    async function cancel() {
      router.push("/")
    }

    async function save(recipeData) {
      isLoading.value = true

      const ingreds = recipeData.ingredients.split("\n").map(x => x.trim()).filter(x => x !== "")

      try {
        const response = await axios.post('/recipes/', {
          name: recipeData.name,
          amounts: recipeData.amounts,
          instructions: recipeData.instructions,
          link: recipeData.link,
          ingredients: ingreds
        }, {
          headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
          }
        })

        router.push("/recipe/" + response.data.id)
      }
      catch (error) {
        isLoading.value = false
        snackbar.value = true
        console.error('Error Creating Recipe: ', error)
      }
    }

    return {
      isLoading,
      snackbar,
      sbText,
      sbtimeout,
      cancel,
      save
    }
  }
}
</script>