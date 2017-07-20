import Vue from 'vue/dist/vue.esm'
import axios from 'axios'
import RequestService from './requestService'

const token = document.getElementsByName('csrf-token')[0].getAttribute('content')
axios.defaults.headers.common['X-CSRF-Token'] = token
axios.defaults.headers.common['Accept'] = 'application/json'

new Vue({
    el: '.diagnosis-step1',
    data: {
        siret: '',
        companyName: '',
        companyLocation: '',
        companyFormDisplayed: true,
        companyInfoDisplayed: false,
        nextStepButtonDisabled: true,
        isSearching: false,
        formHasError: false
    },
    methods: {
        submitSelectCompany: function() {
            return this.siretFormatValid() ? this.fetchCompany() : true // render true to let browser deal with format error message
        },
        siretFormatValid: function() {
            return this.siret.match(/[0-9]{14}/)
        },
        fetchCompany: function() {
            this.isSearching = true

            const requestConfig = {
                method: 'post',
                url: '/api/companies/search_by_siret', // TODO: put url in front end from rails
                params: { siret: this.siret }
            }
            const vm = this
            let onSuccess = function (response) {
                vm.isSearching = false
                vm.companyName = response.data.company_name
                vm.companyLocation = response.data.company_location  // TODO: facility location, not company
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
        saveAndGoToNextStep: function() {
            if(!this.nextStepButtonDisabled) {
                const requestConfig = {
                    method: 'post',
                    url: '/api/diagnosis', // TODO: endpoint to create Diagnosis
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