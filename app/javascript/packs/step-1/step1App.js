import Vue from 'vue/dist/vue.esm'
import axios from 'axios'

import TurbolinksAdapter from 'vue-turbolinks'

Vue.use(TurbolinksAdapter)

import SelectCompany from './selectCompany.vue.erb'

var token
try {
    token = document.getElementsByName('csrf-token')[0].getAttribute('content')
}
catch (e) {
    token = ''
}

axios.defaults.headers.common['X-CSRF-Token'] = token
axios.defaults.headers.common['Accept'] = 'application/json'

new Vue({
    el: '#step1-app',
    components: {
        'select-company': SelectCompany
    }
})
