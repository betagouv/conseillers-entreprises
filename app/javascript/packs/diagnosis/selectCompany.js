import Vue from 'vue/dist/vue.esm'
import axios from 'axios'
import RequestService from './requestService'

const token = document.getElementsByName('csrf-token')[0].getAttribute('content')
axios.defaults.headers.common['X-CSRF-Token'] = token
axios.defaults.headers.common['Accept'] = 'application/json'

// TODO: test

new Vue({
    el: '.diagnosis-step1',
    data: {
        siret: '',
        companyName: '',
        facilityLocation: '',
        companyFormDisplayed: true,
        companyInfoDisplayed: false,
        nextStepButtonDisabled: true,
        isSearching: false,
        formHasError: false
    },
    methods: {
        submitSelectCompany: function(searchFacilityPath) {
            return this.siretFormatValid() ? this.fetchCompany(searchFacilityPath) : true // TODO: Don't use HTML5 errors
        },
        siretFormatValid: function() {
            return this.siret.match(/[0-9]{14}/)
        },
        fetchCompany: function(searchFacilityPath) {
            this.isSearching = true

            const requestConfig = {
                method: 'post',
                url: searchFacilityPath,
                params: { siret: this.siret }
            }
            const vm = this
            let onSuccess = function (response) {
                vm.isSearching = false
                vm.companyName = response.data.company_name
                vm.facilityLocation = response.data.facility_location
                vm.displayCompanyInfo()
            }
            let onError = function (_error) {
                vm.formHasError = true
                vm.isSearching = false
            }

            new RequestService(onSuccess, onError).send(requestConfig)
        },
        displayCompanyForm: function() {
            this.companyFormDisplayed = true
            this.companyInfoDisplayed = false
            this.nextStepButtonDisabled = true
        },
        displayCompanyInfo: function() {
            this.companyFormDisplayed = false
            this.companyInfoDisplayed = true
            this.nextStepButtonDisabled = false
        },
        saveAndGoToNextStep: function(saveDiagnosisPath) {
            if(!this.nextStepButtonDisabled) {
                const requestConfig = {
                    method: 'post',
                    url: saveDiagnosisPath,
                    params: { siret: this.siret }
                }
                let onSuccess = function (response) {

                    Turbolinks.visit('/')
                }
                let onError = function (error) {
                    // TODO: error
                }

                new RequestService(onSuccess, onError).send(requestConfig)
            }
        }
    },
    watch: {
        siret: function(newValue) {
            this.formHasError = false
        }
    }
})