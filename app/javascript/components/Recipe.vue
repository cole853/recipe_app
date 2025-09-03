<template>
    <div>{{ name }}</div>
    <div>{{ amounts }}</div>
    <div>{{ instructions }}</div>
    <div>{{ link }}</div>
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
        // try {
        //     const response = await axios.get('/recipes/' + id);
        // } catch (error) {
        //     console.error('Error Showing Recipe:', error)
        // }

        // const name = ref(response.data.name)
        // const amounts = ref(response.data.amounts)
        // const instructions = ref(response.data.instructions)
        // const link = ref(response.data.link)

        const name = ref('')
        const amounts = ref('')
        const instructions = ref('')
        const link = ref('')

        async function getRecipe() {
            try {
                const response = await axios.get('/recipes/' + props.id);
                name.value = response.data.name
                amounts.value = response.data.amounts
                instructions.value = response.data.instructions
                link.value = response.data.link

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