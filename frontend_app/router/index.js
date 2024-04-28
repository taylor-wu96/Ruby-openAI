import { createRouter, createMemoryHistory, createWebHistory } from 'vue-router';
import Dashboard from '../pages/Dashboard.vue'


const routes = [
  {
    path: '/',
    name: 'Home',
    component: Dashboard,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
