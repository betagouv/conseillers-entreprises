import Vue from 'vue/dist/vue.esm'
import store from './store'
import axios from 'axios'

import visitDateInput from './visitDateInput.vue.erb'
import datePickerInput from './datePickerInput.vue.erb'

var token = document.getElementsByName('csrf-token')[0].getAttribute('content')
axios.defaults.headers.common['X-CSRF-Token'] = token
axios.defaults.headers.common['Accept'] = 'application/json'

new Vue({
    el: '#step3-app',
    store,
    components: {
        'visit-date-input': visitDateInput,
        'date-picker-input': datePickerInput
    }
})