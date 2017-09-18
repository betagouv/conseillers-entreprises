import Vue from 'vue/dist/vue.esm'
import store from './store'

import appDataSetter from './appDataSetter.vue.erb'
import contentTextArea from './contentTextArea.vue.erb'
import questionSelectionRow from './questionSelectionRow.vue.erb'
import questionContentRow from './questionContentRow.vue.erb'
import nextStepButton from '../common/nextStepButton.vue.erb'
import StepRoutingService from '../common/stepRoutingService'

import ErrorService from '../common/errorService'
import TurbolinksAdapter from 'vue-turbolinks'
import AxiosConfigurator from '../common/axiosConfigurator'

Vue.use(TurbolinksAdapter)
AxiosConfigurator.configure()
ErrorService.configureFramework(Vue)

new Vue({ // eslint-disable-line no-new
  el: '#step2-app',
  store,
  components: {
    'app-data-setter': appDataSetter,
    'content-text-area': contentTextArea,
    'question-selection-row': questionSelectionRow,
    'question-content-row': questionContentRow,
    'next-step-button': nextStepButton
  },
  computed: {
    isRequestInProgress: function () {
      return this.$store.state.step2Store.isRequestInProgress
    }
  },
  methods: {
    saveButtonClicked: function () {
      this.$store.dispatch('sendDiagnosisContentUpdate')
        .then(() => {
          return this.$store.dispatch('sendDiagnosedNeedsBulkUpdate')
        })
        .then(() => {
          this.$store.dispatch('getDiagnosisContentValue')
        })
        .then(() => {
          this.$store.dispatch('getDiagnosedNeeds')
        })
        .catch(ErrorService.report)
    },
    nextStepButtonClicked: function () {
      const stepRoutingService = new StepRoutingService(this.$store.state.step2Store.diagnosisId)
      this.$store.dispatch('sendDiagnosisContentUpdate')
        .then(() => {
          return this.$store.dispatch('sendDiagnosedNeedsBulkUpdate')
        })
        .then(() => {
          return stepRoutingService.goToStep(3)
        })
        .catch(ErrorService.report)
    }
  }
})
