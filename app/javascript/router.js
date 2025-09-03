import { createRouter, createWebHistory } from 'vue-router'
import Home from './components/Home.vue'
import Recipe from './components/Recipe.vue'

const routes = [
  { path: '/',
    name: 'Home',
    component: Home
  },
  { path: '/recipe/:id',
    name: 'Recipe',
    component: Recipe,
    props: true
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router