import Step3APIService from './step3APIService'
import * as types from './mutationTypes'

const formCompletionError = new Error('the form is not completed')

const state = {
    isRequestInProgress: false,
    showFormFieldErrors: false,
    showFormErrorMessage: false,
    name: '',
    job: '',
    email: '',
    phoneNumber: '',
    visitDate: '',
    visitId: undefined,
    diagnosisId: undefined,
}

const getters = {

    isNameCompleted: state => {
        return (state.name.length > 0)
    },

    isJobCompleted: state => {
        return (state.job.length > 0)
    },

    areContactDetailsCompleted: state => {
        return (state.email.length > 0 || state.phoneNumber.length > 0)
    },

    isFormCompleted: (state, getters) => {
        return (getters.isNameCompleted
        && getters.isJobCompleted
        && getters.areContactDetailsCompleted)
    },

    isDateCompleted: state => {
        return (state.visitDate.length > 0)
    }
}

const actions = {

    launchNextStep ({dispatch, commit, state, getters}) {
        commit(types.REQUEST_IN_PROGRESS, true)
        commit(types.FORM_FIELDS_ERROR, true)
        commit(types.FORM_ERROR_MESSAGE, false)

        return dispatch('checkFormCompletion')
            .then(() => {
                return dispatch('updateVisitDate')
            })
            .then(() => {
                return dispatch('createContact')
            })
            .then(() => {
                commit(types.REQUEST_IN_PROGRESS, false)
            })
            .catch((error) => {
                commit(types.REQUEST_IN_PROGRESS, false)
                commit(types.FORM_ERROR_MESSAGE, error == formCompletionError ? false : true)
                throw error
            })
    },

    checkFormCompletion ({getters}) {

        return new Promise((resolve, reject) => {
            getters.isFormCompleted && getters.isDateCompleted ? resolve(true) : reject(formCompletionError)
        })

    },

    updateVisitDate ({state, step3APIServiceDependency}) {
        var step3APIService = step3APIServiceDependency
        if (typeof step3APIService == 'undefined') {
            step3APIService = Step3APIService
        }

        return step3APIService.updateVisitDate(state.visitId, state.visitDate)
    },

    createContact ({state, step3APIServiceDependency}) {
        var step3APIService = step3APIServiceDependency
        if (typeof step3APIService == 'undefined') {
            step3APIService = Step3APIService
        }

        const contactData = {
            full_name: state.name,
            email: state.email,
            phone_number: state.phoneNumber,
            role: state.job
        }
        return step3APIService.createContactForVisit(state.visitId, contactData)
    }
}

const mutations = {

    [types.REQUEST_IN_PROGRESS] (state, isRequestInProgress) {
        state.isRequestInProgress = isRequestInProgress
    },

    [types.CONTACT_NAME] (state, name) {
        state.name = name
    },

    [types.CONTACT_JOB] (state, job) {
        state.job = job
    },

    [types.CONTACT_EMAIL] (state, email) {
        state.email = email
    },

    [types.CONTACT_PHONE_NUMBER] (state, phoneNumber) {
        state.phoneNumber = phoneNumber
    },

    [types.VISIT_DATE] (state, visitDate) {
        state.visitDate = visitDate
    },

    [types.VISIT_ID] (state, visitId) {
        state.visitId = visitId
    },

    [types.FORM_FIELDS_ERROR] (state, showFormFieldErrors) {
        state.showFormFieldErrors = showFormFieldErrors
    },

    [types.FORM_ERROR_MESSAGE] (state, showFormErrorMessage) {
        state.showFormErrorMessage = showFormErrorMessage
    },

    [types.DIAGNOSIS_ID] (state, diagnosisId) {
        state.diagnosisId = diagnosisId
    }
}

export default {
    state,
    getters,
    actions,
    mutations
}