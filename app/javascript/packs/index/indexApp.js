import Vue from 'vue/dist/vue.esm'
import store from './store'

import selectCompany from './selectCompany.vue.erb'
// import StepRoutingService from '../common/stepRoutingService'

import TurbolinksAdapter from 'vue-turbolinks'
import AxiosConfigurator from '../common/axiosConfigurator'

Vue.use(TurbolinksAdapter)
AxiosConfigurator.configure()

new Vue({
    el: '#index-app',
    store,
    components: {
        'select-company': selectCompany
    }
})

