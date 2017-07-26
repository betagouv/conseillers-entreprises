import Vue from 'vue/dist/vue.esm'

import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter)

import SelectCompany from './selectCompany.vue.erb'

new Vue({
    el: '#step1-app',
    components: {
        'select-company': SelectCompany
    }
})
