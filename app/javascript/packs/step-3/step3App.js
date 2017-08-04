import Vue from 'vue/dist/vue.esm'
import store from './store'
import axios from 'axios'

import appDataSetter from './appDataSetter.vue.erb'
import visitDateInput from './visitDateInput.vue.erb'
import contactForm from './contactForm.vue.erb'
import formErrorMessage from './formErrorMessage.vue.erb'
import nextStepButton from '../common/nextStepButton.vue.erb'

var token
var configureNextStepButton = function (that) {
    nextStepButton.computed.isRequestInProgress = function() {
        return that.$store.state.step3Store.isRequestInProgress
    }

    nextStepButton.methods.nextStepButtonClicked = function () {
        const url = `/diagnoses/${that.$store.state.step3Store.diagnosisId}/step-4`
        that.$store.dispatch('launchNextStep')
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
        configureNextStepButton(this)
    }
})

