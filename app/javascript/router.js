// Code from https://engineering.terakeet.com/posts/integrating-vite-and-vue-with-rails-7/
import { createRouter, createWebHistory } from 'vue-router'
import Home from './components/Home.vue'

const routes = [
  { path: '/', component: Home }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router