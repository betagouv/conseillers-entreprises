import Vue from 'vue/dist/vue.esm'
import store from './store'

import appDataSetter from './appDataSetter.vue.erb'
import visitDateInput from './visitDateInput.vue.erb'
import contactForm from './contactForm.vue.erb'
import formErrorMessage from './formErrorMessage.vue.erb'
import nextStepButton from '../common/nextStepButton.vue.erb'
import StepRoutingService from '../common/stepRoutingService'

import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter)

import AxiosConfigurator from '../common/axiosConfigurator'
AxiosConfigurator.configure()

new Vue({
    el: '#step3-app',
    store,
    components: {
        'app-data-setter': appDataSetter,
        'visit-date-input': visitDateInput,
        'contact-form': contactForm,
        'form-error-message': formErrorMessage,
        'next-step-button': nextStepButton
    },
    beforeCreate: function () {
        // configureNextStepButton(this)
    },
    computed: {
        isRequestInProgress: function() {
            return this.$store.state.step3Store.isRequestInProgress
        },
        areModificationDisabled: function() {
            return this.$store.getters.areModificationDisabled
        },
    },
    methods: {
        nextStepButtonClicked:function () {
            const stepRoutingService = new StepRoutingService(this.$store.state.step3Store.diagnosisId)
            this.$store.dispatch('launchNextStep')
                .then(() => {
                    return stepRoutingService.goToStep(4)
                })
                .catch((error) => {
                })
        }
    },
})

