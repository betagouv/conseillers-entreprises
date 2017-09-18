import Vue from 'vue/dist/vue.esm'

import SelectCompany from '../common/companySearch/selectCompany.vue.erb'
import NextStepButton from '../common/nextStepButton.vue.erb'
import Step1APIService from './utils/step1APIService'
import StepRoutingService from '../common/stepRoutingService'
import store from './store'
import TurbolinksAdapter from 'vue-turbolinks'
import AxiosConfigurator from '../common/axiosConfigurator'
import ErrorService from '../common/errorService'

Vue.use(TurbolinksAdapter)
AxiosConfigurator.configure()
ErrorService.configureFramework(Vue)

new Vue({ // eslint-disable-line no-new
  el: '#step1-app',
  store,
  components: {
    SelectCompany,
    NextStepButton
  },
  data: {
    isRequestInProgress: false
  },
  computed: {
    hasData: function () {
      return Boolean(this.$store.state.searchStore.companyData.siret)
    },
    isButtonDisabled: function () {
      return !this.hasData
    }
  },
  methods: {
    nextStepButtonClicked: function () {
      this.isRequestInProgress = true
      Step1APIService.createDiagnosis(this.$store.state.searchStore.companyData.siret)
        .then((diagnosisId) => {
          this.isRequestInProgress = false
          const stepRoutingService = new StepRoutingService(diagnosisId)
          return stepRoutingService.goToStep(2)
        })
        .catch(ErrorService.report)
    }
  }
})
