import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import step3Store from './step3Store'

Vue.use(Vuex)

const debug = process.env.NODE_ENV !== 'production'

export default new Vuex.Store({
  modules: {
    step3Store
  },
  strict: debug
})
