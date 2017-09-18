import Vue from 'vue/dist/vue.esm'
import store from './store'

import appDataSetter from './appDataSetter.vue.erb'
import visitDateInput from './visitDateInput.vue.erb'
import contactForm from './contactForm.vue.erb'
import formErrorMessage from './formErrorMessage.vue.erb'
import nextStepButton from '../common/nextStepButton.vue.erb'
import StepRoutingService from '../common/stepRoutingService'

import ErrorService from '../common/errorService'
import TurbolinksAdapter from 'vue-turbolinks'
import AxiosConfigurator from '../common/axiosConfigurator'

Vue.use(TurbolinksAdapter)
AxiosConfigurator.configure()
ErrorService.configureFramework(Vue)

new Vue({ // eslint-disable-line no-new
  el: '#step3-app',
  store,
  components: {
    'app-data-setter': appDataSetter,
    'visit-date-input': visitDateInput,
    'contact-form': contactForm,
    'form-error-message': formErrorMessage,
    'next-step-button': nextStepButton
  },
  computed: {
    isRequestInProgress: function () {
      return this.$store.state.step3Store.isRequestInProgress
    },
    isFormDisabled: function () {
      return this.$store.getters.isFormDisabled
    }
  },
  methods: {
    previousStepButtonClicked: function () {
      const stepRoutingService = new StepRoutingService(this.$store.state.step3Store.diagnosisId)
      return stepRoutingService.goToStep(2)
        .catch(ErrorService.report)
    },
    nextStepButtonClicked: function () {
      const stepRoutingService = new StepRoutingService(this.$store.state.step3Store.diagnosisId)
      this.$store.dispatch('launchNextStep')
        .then(() => {
          return stepRoutingService.goToStep(4)
        })
        .catch(ErrorService.report)
    }
  }
})
