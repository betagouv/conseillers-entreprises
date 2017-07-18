import Vue from 'vue'
import Vuex from 'vuex'
import contactStore from './contactStore'

Vue.use(Vuex);

const debug = process.env.NODE_ENV !== 'production';

export default new Vuex.Store({
    modules: {
        contactStore
    },
    strict: debug
});