import Vue from 'vue/dist/vue.esm'
import store from './store'
import axios from 'axios'

import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter)

import appDataSetter from './appDataSetter.vue.erb'
import contentTextArea from './contentTextArea.vue.erb'
import questionSelectionRow from './questionSelectionRow.vue.erb'
import questionContentRow from './questionContentRow.vue.erb'
import nextStepButton from '../common/nextStepButton.vue.erb'

var token
var configureNextStepButton = function (that) {
    nextStepButton.computed.isRequestInProgress = function() {
        return that.$store.state.step2Store.isRequestInProgress
    }

    nextStepButton.methods.nextStepButtonClicked = function () {
        const url = `/diagnoses/${that.$store.state.step2Store.diagnosisId}/step-3`
        that.$store.dispatch('sendDiagnosisContentUpdate')
            .then(() => {
                return that.$store.dispatch('createSelectedQuestions')
            })
            .then(() => {
                Turbolinks.visit(url)
            })
            .catch((error) => {
            })
    }
}

try {
    token = document.getElementsByName('csrf-token')[0].getAttribute('content')
}
catch (e) {
    token = ''
}

axios.defaults.headers.common['X-CSRF-Token'] = token
axios.defaults.headers.common['Accept'] = 'application/json'

new Vue({
    el: '#step2-app',
    store,
    components: {
        'app-data-setter': appDataSetter,
        'content-text-area': contentTextArea,
        'question-selection-row': questionSelectionRow,
        'question-content-row': questionContentRow,
        'next-step-button': nextStepButton
    },
    beforeCreate: function () {
        configureNextStepButton(this)
    }
})

