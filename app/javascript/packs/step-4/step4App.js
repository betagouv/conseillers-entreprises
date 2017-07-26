import Vue from 'vue/dist/vue.esm'

import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter)

import SelectExperts from './selectExperts.vue.erb'

new Vue({
    el: '#step4-app',
    components: {
        'select-experts': SelectExperts
    }
})
