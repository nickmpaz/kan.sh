import Vue from 'vue'
import VueRouter from 'vue-router'
import {
    Auth
} from 'aws-amplify';

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Index',
    component: () => import('../views/Index.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/board/:board_id',
    name: 'Board',
    component: () => import('../views/Board.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/settings',
    name: 'Settings',
    component: () => import('../views/Settings.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/auth',
    name: 'Auth',
    component: () => import('../views/Auth.vue'),
    meta: { requiresNoAuth: true }
  }
]
const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

router.beforeResolve((to, from, next) => {
  var loggedIn = false
  Auth.currentAuthenticatedUser()
    .then(() => {
        loggedIn = true
    })
    .catch(() => {
        loggedIn = false
    })
    .finally(() => {
      if (to.matched.some(record => record.meta.requiresAuth) && !loggedIn) {
        next('/auth')
      } else if (
        to.matched.some(record => record.meta.requiresNoAuth) &&
        loggedIn
      ) {
        next('/')
      }
      next()
    })
})



export default router
