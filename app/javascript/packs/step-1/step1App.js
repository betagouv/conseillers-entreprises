import Vue from 'vue/dist/vue.esm'
import TurbolinksAdapter from 'vue-turbolinks'
import SelectCompany from './selectCompany.vue.erb'

Vue.use(TurbolinksAdapter)

new Vue({
    el: '#step1-app',
    components: {
        'select-company': SelectCompany
    }
})
