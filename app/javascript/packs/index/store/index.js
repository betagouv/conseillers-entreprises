import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import indexStore from './indexStore'

Vue.use(Vuex)

const debug = process.env.NODE_ENV !== 'production'

export default new Vuex.Store({
    modules: {
        indexStore
    },
    strict: debug
})
