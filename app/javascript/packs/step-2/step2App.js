import Vue from 'vue/dist/vue.esm'
import store from './store'

import appDataSetter from './appDataSetter.vue.erb'
import contentTextArea from './contentTextArea.vue.erb'
import questionSelectionRow from './questionSelectionRow.vue.erb'
import questionContentRow from './questionContentRow.vue.erb'
import nextStepButton from '../common/nextStepButton.vue.erb'
import StepRoutingService from '../common/stepRoutingService'

import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter)

var token
var configureNextStepButton = function (that) {
    nextStepButton.computed.isRequestInProgress = function() {
        return that.$store.state.step2Store.isRequestInProgress
    }

    nextStepButton.methods.nextStepButtonClicked = function () {
        const stepRoutingService = new StepRoutingService(that.$store.state.step2Store.diagnosisId)
        that.$store.dispatch('sendDiagnosisContentUpdate')
            .then(() => {
                return that.$store.dispatch('createSelectedQuestions')
            })
            .then(() => {
                return stepRoutingService.goToStep(3)
            })
            .catch((error) => {
            })
    }
}

import AxiosConfigurator from '../common/axiosConfigurator'
AxiosConfigurator.configure()

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

