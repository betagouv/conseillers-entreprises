import Step3APIService from './step3APIService'
import * as types from './mutationTypes'

const formCompletionError = new Error('the form is not completed')

const state = {
    isInitialLoadingInProgress: false,
    isRequestInProgress: false,
    showFormFieldErrors: false,
    showFormErrorMessage: false,
    name: '',
    job: '',
    email: '',
    phoneNumber: '',
    visitDate: '',
    visitId: undefined,
    contactId: undefined,
    diagnosisId: undefined
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
        return (getters.isNameCompleted &&
            getters.isJobCompleted &&
            getters.areContactDetailsCompleted)
    },

    isDateCompleted: state => {
        return (state.visitDate.length > 0)
    },

    isFormDisabled: state => {
        return state.isRequestInProgress || state.isInitialLoadingInProgress
    }
}

const actions = {

    getInitialData({dispatch, commit, state, getters}) {
        commit(types.INITIAL_LOADING_IN_PROGRESS, true)

        return dispatch('getVisitData')
            .then((data) => {
                commit(types.VISIT_DATE, data.happened_at)
                commit(types.CONTACT_ID, data.visitee_id)
                return data.visitee_id
            })
            .then((visitee_id) => {
                if (typeof visitee_id !== 'undefined' && visitee_id != null) {
                    return dispatch('getContactData')
                }
            })
            .then((data) => {
                if(typeof data !== 'undefined') {
                    commit(types.CONTACT_NAME, data.full_name)
                    commit(types.CONTACT_JOB, data.role)
                    commit(types.CONTACT_EMAIL, data.email)
                    commit(types.CONTACT_PHONE_NUMBER, data.phone_number)
                }
            })
            .then(() => {
                commit(types.INITIAL_LOADING_IN_PROGRESS, false)
            })
            .catch((error) => {
                commit(types.INITIAL_LOADING_IN_PROGRESS, false)
                commit(types.FORM_ERROR_MESSAGE, error != formCompletionError)
                throw error
            })
    },

    launchNextStep({dispatch, commit, state, getters}) {
        commit(types.REQUEST_IN_PROGRESS, true)
        commit(types.FORM_FIELDS_ERROR, true)
        commit(types.FORM_ERROR_MESSAGE, false)

        return dispatch('checkFormCompletion')
            .then(() => {
                return dispatch('updateVisitDate')
            })
            .then(() => {
                if(typeof state.contactId !== 'undefined' && state.contactId != null) {
                    return dispatch('updateContact')
                } else {
                    return dispatch('createContact')
                }
            })
            .then(() => {
                commit(types.REQUEST_IN_PROGRESS, false)
            })
            .catch((error) => {
                commit(types.REQUEST_IN_PROGRESS, false)
                throw error
            })
    },

    checkFormCompletion({getters}) {
        return new Promise((resolve, reject) => {
            getters.isFormCompleted && getters.isDateCompleted ? resolve(true) : reject(formCompletionError)
        })
    },

    updateVisitDate({state, step3APIServiceDependency}) {
        var step3APIService = step3APIServiceDependency
        if (typeof step3APIService === 'undefined') {
            step3APIService = Step3APIService
        }

        return step3APIService.updateVisitDate(state.visitId, state.visitDate)
    },

    getVisitData({state, step3APIServiceDependency}) {
        var step3APIService = step3APIServiceDependency
        if (typeof step3APIService === 'undefined') {
            step3APIService = Step3APIService
        }

        return step3APIService.getVisitFromId(state.visitId)
    },

    getContactData({state, step3APIServiceDependency}) {
        var step3APIService = step3APIServiceDependency
        if (typeof step3APIService === 'undefined') {
            step3APIService = Step3APIService
        }

        return step3APIService.getContactFromId(state.contactId)
    },

    createContact({state, step3APIServiceDependency}) {
        var step3APIService = step3APIServiceDependency
        if (typeof step3APIService === 'undefined') {
            step3APIService = Step3APIService
        }

        const contactData = {
            full_name: state.name,
            email: state.email,
            phone_number: state.phoneNumber,
            role: state.job
        }
        return step3APIService.createContactForVisit(state.visitId, contactData)
    },

    updateContact({state, step3APIServiceDependency}) {
        var step3APIService = step3APIServiceDependency
        if (typeof step3APIService === 'undefined') {
            step3APIService = Step3APIService
        }

        const contactData = {
            full_name: state.name,
            email: state.email,
            phone_number: state.phoneNumber,
            role: state.job
        }
        return step3APIService.updateContact(state.contactId, contactData)
    }
}

const mutations = {

    [types.INITIAL_LOADING_IN_PROGRESS](state, isInitialLoadingInProgress) {
        state.isInitialLoadingInProgress = isInitialLoadingInProgress
    },

    [types.REQUEST_IN_PROGRESS](state, isRequestInProgress) {
        state.isRequestInProgress = isRequestInProgress
    },

    [types.CONTACT_ID](state, contactId) {
        state.contactId = contactId
    },

    [types.CONTACT_NAME](state, name) {
        state.name = name
    },

    [types.CONTACT_JOB](state, job) {
        state.job = job
    },

    [types.CONTACT_EMAIL](state, email) {
        state.email = email
    },

    [types.CONTACT_PHONE_NUMBER](state, phoneNumber) {
        state.phoneNumber = phoneNumber
    },

    [types.VISIT_DATE](state, visitDate) {
        if(typeof visitDate == 'string') {
            state.visitDate = visitDate
        }
    },

    [types.VISIT_ID](state, visitId) {
        state.visitId = visitId
    },

    [types.FORM_FIELDS_ERROR](state, showFormFieldErrors) {
        state.showFormFieldErrors = showFormFieldErrors
    },

    [types.FORM_ERROR_MESSAGE](state, showFormErrorMessage) {
        state.showFormErrorMessage = showFormErrorMessage
    },

    [types.DIAGNOSIS_ID](state, diagnosisId) {
        state.diagnosisId = diagnosisId
    }
}

export default {
    state,
    getters,
    actions,
    mutations
}
