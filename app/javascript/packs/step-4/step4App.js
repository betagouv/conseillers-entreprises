import Vue from 'vue/dist/vue.esm'

import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter)

new Vue({
    el: '#step4-app',
    data: {
        selectedAssistanceExperts: [],
        selectedAssistanceExpertsCount: 0
    },
    methods: {
        selectAll: function() {
            this.changeCheckboxesFor(true)
        },
        unSelectAll: function() {
            this.changeCheckboxesFor(false)
        },
        changeCheckboxesFor: function(newValue) {
            let checkboxes = document.getElementsByTagName('input')
            for(let i = 0; i < checkboxes.length; i++) {
                if(checkboxes[i].type === 'checkbox') {
                    checkboxes[i].checked = newValue
                }
            }
        }
    },
    watch: {
        selectedAssistanceExperts: function(_newValue) {
            this.selectedAssistanceExpertsCount = this.selectedAssistanceExperts.length
        }
    }
})
