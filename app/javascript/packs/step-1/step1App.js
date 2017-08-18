import Vue from 'vue/dist/vue.esm'

import TurbolinksAdapter from 'vue-turbolinks'

Vue.use(TurbolinksAdapter)

import SelectCompany from './selectCompany.vue.erb'
import AxiosConfigurator from '../common/axiosConfigurator'
AxiosConfigurator.configure()

new Vue({
    el: '#step1-app',
    components: {
        'select-company': SelectCompany
    }
})
