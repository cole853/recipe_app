<template>
  <v-card style="background-color: #455A64" class="mx-auto rounded-lg" :style="{ width: cardWidth, border: '10px solid #455A64' }">

    <v-text-field 
      clearable 
      variant="solo-filled"
      color="#5EC7A1"
      backgroundColor="white"
      placeholder="Fruit Salad"
      label="Recipe name"
      v-model="recipeName"
    />

    <v-textarea
      clearable
      variant="solo-filled"
      color="#5EC7A1"
      backgroundColor="white"
      placeholder="1 c. grapes\n3 chopped apples\n2 c. strawberries\n2 oranges\n..."
      label="Ingredient amounts"
      v-model="amounts"
    />
        
    <v-textarea
      clearable
      variant="solo-filled"
      color="#5EC7A1"
      backgroundColor="white"
      label="Search ingredients"
      placeholder="grapes\napples\nstrawberries\noranges\n..."
      v-model="ingredients"
    />
        
    <v-textarea
      clearable
      variant="solo-filled"
      color="#5EC7A1"
      backgroundColor="white"
      label="Directions"
      v-model="instructions"
    />


    <v-text-field 
      clearable 
      variant="solo-filled"
      color="#5EC7A1"
      backgroundColor="white"
      label="Link to recipe"
      v-model="link"
    />
    
    <div class="d-flex justify-end">
      <v-btn @click="cancel" rounded="xl" class="mr-4 custom-btn">Cancel</v-btn>
      <v-btn @click="save" rounded="xl" class="mr-4 mb-4 text-black" color="#5EC7A1">OK</v-btn>
    </div>
  </v-card>
</template>

<script>
import { computed, ref } from 'vue'
import { useDisplay } from 'vuetify'

export default {
  name: "RecipeEdit",
  props: {
    recipeName: { type: String, default: '' },
    amounts: { type: String, default: '' },
    instructions: { type: String, default: '' },
    link: { type: String, default: '' },
    ingredients: { type: String, default: '' }
  },
  setup(props, { emit }) {
    const recipeName = ref(props.recipeName)
    const amounts = ref(props.amounts)
    const instructions = ref(props.instructions)
    const link = ref(props.link)
    const ingredients = ref(props.ingredients)

    const { name } = useDisplay()

    const cardWidth = computed(() => {
      const widths = {
        sm: '600px',
        md: '700px',
        lg: '800px'
      }
      return widths[name.value] || '800px'
    })

    // save the recipe
    function save() {
      const recipeData = {
        name: recipeName.value,
        amounts: amounts.value,
        instructions: instructions.value,
        link: link.value,
        ingredients: ingredients.value
      }
      emit('save', recipeData)
    }

    // cancel the recipe edit or creation
    function cancel() {
      emit('cancel')
    }

    return {
      cardWidth,
      recipeName,
      amounts,
      instructions,
      link,
      ingredients,
      save,
      cancel
    }
  }
}
</script>