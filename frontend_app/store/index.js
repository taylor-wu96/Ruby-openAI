import { reactive } from 'vue'
import { createStore } from 'vuex'

export default createStore({
  state: reactive({
    sharedVariable: {
      'user_id': '',
      submitted: false
    }
  }),
  mutations: {
    updateSharedVariable(state, payload) {
      state.sharedVariable = { ...state.sharedVariable, ...payload }
    }
  },
  getters: {
    getSharedVariable: state => state.sharedVariable
  }
})
