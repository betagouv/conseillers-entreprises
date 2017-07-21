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
        isLoading: false,
        siretFormatError: false,
        companyNotFoundError: false,
        diagnosisSaveError: false
    },
    methods: {
        submitSelectCompany: function(searchFacilityPath) {
            if(this.siretFormatValid()) {
                this.fetchCompany(searchFacilityPath)
            } else {
                this.siretFormatError = true
            }
        },
        siretFormatValid: function() {
            return this.siret.match(/^[0-9]{14}$/)
        },
        fetchCompany: function(searchFacilityPath) {
            this.isLoading = true

            const requestConfig = {
                method: 'post',
                url: searchFacilityPath,
                params: { siret: this.siret }
            }
            const vm = this
            let onSuccess = function (response) {
                vm.isLoading = false
                vm.companyName = response.data.company_name
                vm.facilityLocation = response.data.facility_location
                vm.displayCompanyInfo()
                document.getElementById('next-step-button').focus()
            }
            let onError = function (_error) {
                vm.companyNotFoundError = true
                vm.isLoading = false
            }

            new RequestService(onSuccess, onError).send(requestConfig)
        },
        editCompanyForm: function() {
            this.removeErrors()
            this.displayCompanyForm()
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
                this.removeErrors()
                this.isLoading = true

                const requestConfig = {
                    method: 'post',
                    url: saveDiagnosisPath,
                    params: { siret: this.siret }
                }
                const vm = this
                let onSuccess = function (response) {
                    vm.isLoading = false
                    Turbolinks.visit(`/diagnosis_v2/${response.data.id}/step-2`) // TODO: Test this route presence
                }
                let onError = function (error) {
                    vm.diagnosisSaveError = true
                    vm.isLoading = false
                }

                new RequestService(onSuccess, onError).send(requestConfig)
            }
        },
        formHasError: function() {
            return this.siretFormatError || this.companyNotFoundError || this.diagnosisSaveError
        },
        removeErrors: function() {
            this.siretFormatError = false
            this.companyNotFoundError = false
            this.diagnosisSaveError = false
        }
    },
    watch: {
        siret: function(newValue) {
            this.removeErrors()
        }
    }
})
