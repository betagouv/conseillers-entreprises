import Vue from 'vue/dist/vue.esm'
import TurbolinksAdapter from 'vue-turbolinks'
import First from './first.vue.erb'

Vue.use(TurbolinksAdapter)

document.addEventListener('turbolinks:load', () => {
    const element = document.getElementById('diagnosis-step1')
    if (element !== null) {
        new Vue({
            el: element,
            components: {
                'first': First
            }
        })
    }
})
