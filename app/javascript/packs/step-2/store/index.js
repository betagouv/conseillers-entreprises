import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import step2Store from './step2Store'

Vue.use(Vuex);

const debug = process.env.NODE_ENV !== 'production';

export default new Vuex.Store({
    modules: {
        step2Store
    },
    strict: debug
});