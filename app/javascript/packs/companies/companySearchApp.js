import Vue from 'vue/dist/vue.esm'
import store from './store'

import SelectCompany from '../common/companySearch/selectCompany.vue.erb'

import TurbolinksAdapter from 'vue-turbolinks'
import AxiosConfigurator from '../common/axiosConfigurator'

Vue.use(TurbolinksAdapter)
AxiosConfigurator.configure()

new Vue({
    el: '#company-search-app',
    store,
    components: {
        SelectCompany
    }
})

