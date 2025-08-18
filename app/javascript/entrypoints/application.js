// Code from https://engineering.terakeet.com/posts/integrating-vite-and-vue-with-rails-7/
import { createApp } from 'vue'
import App from '../components/App.vue'
import router from '../router.js'
import { createVuetify } from 'vuetify';
import 'vuetify/styles';
import * as components from 'vuetify/components';
import * as directives from 'vuetify/directives';
import '@mdi/font/css/materialdesignicons.css';

const vuetify = createVuetify({
  components,
  directives,
});

document.addEventListener('DOMContentLoaded', () => {
  const app = createApp(App);
  app.use(router);
  app.use(vuetify);
  app.mount('#app');
});
