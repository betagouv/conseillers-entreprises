import Vue from 'vue/dist/vue.esm'
import store from './store'

import SelectCompany from '../common/companySearch/selectCompany.vue.erb'

import TurbolinksAdapter from 'vue-turbolinks'
import AxiosConfigurator from '../common/axiosConfigurator'
import ErrorService from '../common/errorService'

Vue.use(TurbolinksAdapter)
AxiosConfigurator.configure()
ErrorService.configure()

new Vue({
    el: '#company-search-app',
    store,
    components: {
        SelectCompany
    }
})

