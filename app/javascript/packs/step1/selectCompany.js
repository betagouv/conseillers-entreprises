import Vue from 'vue/dist/vue.esm'
import TurbolinksAdapter from 'vue-turbolinks'
import First from './first.vue.erb'

Vue.use(TurbolinksAdapter)

document.addEventListener('turbolinks:load', () => {
    const element = document.getElementById('diagnosis-step1')
    if(element !== null) {
        SelectCompany.initialize()
    }
})

const SelectCompany = {
    initialize: function() {
        new Vue({
            el: '#diagnosis-step1',
            components: {
                'first': First
            }
        })
    }
}

export default SelectCompany