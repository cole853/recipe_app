import { createRouter, createWebHistory } from 'vue-router'
import Home from './components/Home.vue'
import Recipe from './components/Recipe.vue'
import Create from './components/Create.vue'

const routes = [
  { path: '/',
    name: 'Home',
    component: Home
  },
  { path: '/recipe/:id',
    name: 'Recipe',
    component: Recipe,
    props: true
  },
  { path: '/create',
    name: 'Create',
    component: Create,
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router