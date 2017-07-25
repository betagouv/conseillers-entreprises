import Step3APIService from './step3APIService'
import * as types from './mutationTypes'

const state = {
    isRequestInProgress: false,
    name: '',
    job: '',
    email: '',
    phoneNumber: ''
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
        return (getters.isNameCompleted(state)
        && getters.isJobCompleted(state)
        && getters.areContactDetailsCompleted(state))
    }
}

const actions = {}

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
    }
}

export default {
    state,
    getters,
    actions,
    mutations
}