import { createRouter, createMemoryHistory, createWebHistory } from 'vue-router';
import Dashboard from '../pages/Dashboard.vue'
import Submission from '../pages/Submission.vue'
import Misformat from '../pages/Misformat.vue'


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
  {
    path: '/missing',
    name: 'Missing',
    component: Misformat,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
