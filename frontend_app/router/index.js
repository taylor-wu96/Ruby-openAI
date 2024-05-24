import { createRouter, createMemoryHistory, createWebHistory } from 'vue-router';
import Dashboard from '../pages/Dashboard.vue'
import Submission from '../pages/Submission.vue'


const routes = [
  {
    path: '/',
    name: 'Home',
    component: Dashboard,
  },
  {
    path: '/submitted',
    name: 'Submitted',
    component: Submission,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
