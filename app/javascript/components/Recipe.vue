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
    <v-overlay persistent :model-value="isLoading" class="align-center justify-center">
      <v-card class="pa-4 text-center">
        <v-progress-circular indeterminate size="64"/>
        <div class="mt-4">Loading recipe...</div>
      </v-card>
    </v-overlay>

    <!-- App bar -->
    <v-app-bar app color="#5EC7A1">
      <v-btn :to="'/'" class="custom-btn ml-2" style="position: absolute; left: 16px;">back</v-btn>
      <v-app-bar-title class="text-center">
        {{ name }}
      </v-app-bar-title>
      <div style="position: absolute; right: 16px;">
        <v-btn @click="editDialog = true" class="custom-btn mr-2">edit</v-btn>
        <v-btn @click="delDialog = true" class="custom-btn mr-2">delete</v-btn>
      </div>
    </v-app-bar>

    <!-- delete dialog -->
    <div class="text-center pa-4">
      <v-dialog v-model="delDialog" width="auto">
        <v-card class="text-black" color="#455A64" max-width="400">
          <v-card-title>Are you sure?</v-card-title>
          <v-card-text>{{ name }} will be removed along with ingredients that are no longer used.</v-card-text>
          <v-btn color="#5EC7A1" @click="delDialog = false" text="Cancel"/>
          <v-btn @click="deleteRecipe" class="text-black" color="#b43e69" text="Delete"/>
        </v-card>
      </v-dialog>
    </div>

    <!-- edit dialog -->
    <div class="text-center pa-4">
      <v-overlay persistent v-model="editDialog" class="align-center justify-center">
        <v-card style="background-color: #455A64" class="mx-auto d-flex rounded-lg" min-width="800px" :style="{ border: '3px solid #b43e69' }">
          <RecipeEdit
          :recipe-name="name"
          :instructions="instructions"
          :amounts="amounts"
          :link="link"
          :ingredients="ingredients"
          @cancel="editDialog = false"
          @save="editRecipe"
          />
        </v-card>
      </v-overlay>
    </div>
  
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
import { useRouter } from 'vue-router'
import RecipeEdit from './RecipeEdit.vue'

export default {
  props: {
    id: String,
    required: true
  },
  components: {
    RecipeEdit
  },
  setup (props) {
    const name = ref('')
    const amounts = ref('')
    const instructions = ref('')
    const link = ref('')
    const ingredients = ref('')
    const isLoading = ref(true)
    const delDialog = ref(false)
    const editDialog = ref(false)

    const router = useRouter()

    const snackbar = ref(false)
    const sbText = ref("Save was unsuccessful\nonly the link can be left blank")
    const sbtimeout = ref(3000)

    // gets the recipe information and sets values
    async function getRecipe() {
      try {
        isLoading.value = true
        const response = await axios.get('/recipes/' + props.id)
        name.value = response.data.name
        amounts.value = response.data.amounts
        instructions.value = response.data.instructions.replace("\\u00b0", "\u00b0")
        link.value = response.data.link
        ingredients.value = response.data.ingredients.toString().replace(/,/g, "\n")
        isLoading.value = false

      } catch (error) {
        console.error('Error Showing Recipe: ', error)
      }
    }

    // delete the recipe
    async function deleteRecipe() {
      try {
        router.push({
          path: '/',
          query: {
            deleted: true,
            Id: props.id
          }
        })

        const response = await axios.delete('/recipes/' + props.id, {
          headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
          }
        })
      }
      catch (error) {
        console.error('Error Deleting Recipe: ', error)
      }
    }

    // edit the recipe
    async function editRecipe(recipeData) {
      editDialog.value = false
      isLoading.value = true

      const ingreds = recipeData.ingredients.split("\n").map(x => x.trim()).filter(x => x !== "")

      try {
        const response = await axios.patch('/recipes/' + props.id, {
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

        getRecipe()
      }
      catch (error) {
        snackbar.value = true
        console.error('Error Updating Recipe: ', error)
      }
    }

    onMounted(getRecipe)
    watch(() => props.id, getRecipe)

    return {
      name,
      amounts,
      instructions,
      link,
      ingredients,
      isLoading,
      delDialog,
      editDialog,
      snackbar,
      sbText,
      sbtimeout,
      deleteRecipe,
      editRecipe
    }
  }
}
</script>