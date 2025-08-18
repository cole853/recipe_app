<!-- Code from https://engineering.terakeet.com/posts/integrating-vite-and-vue-with-rails-7/ -->
<template>
  <v-app>
    <v-main>
      <router-view></router-view>
    </v-main>
  </v-app>
</template>

<script>
export default {
  name: 'App',
}
</script>