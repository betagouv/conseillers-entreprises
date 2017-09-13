import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import searchStore from '../../common/companySearch/store/searchStore'

Vue.use(Vuex)

const debug = process.env.NODE_ENV !== 'production'

export default new Vuex.Store({
  modules: {
      searchStore
  },
  strict: debug
})
