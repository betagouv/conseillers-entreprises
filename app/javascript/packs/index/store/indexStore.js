// import Step3APIService from './step3APIService'
import * as types from './indexMutationTypes'

const state = {
    isRequestInProgress: false,
    showFormErrorMessage: false,
    siret: ''
}

const getters = {
}

const actions = {
}

const mutations = {
    [types.REQUEST_IN_PROGRESS](state, isRequestInProgress) {
        state.isRequestInProgress = isRequestInProgress
    },

    [types.FORM_ERROR_MESSAGE](state, showFormErrorMessage) {
        state.showFormErrorMessage = showFormErrorMessage
    },

    [types.SIRET](state, siret) {
        state.siret = siret
    }
}

export default {
    state,
    getters,
    actions,
    mutations
}
