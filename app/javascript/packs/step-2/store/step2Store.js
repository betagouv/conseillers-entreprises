import Step2APIService from './step2APIService'
import * as types from './mutationTypes'

const state = {
    diagnosisContent: '',
    diagnosisId: undefined,
    isDiagnosisRequestUnderWay: false
}

const getters = {}

const actions = {

    sendDiagnosisContentUdpate ({commit, state, step2APIServiceDependency}) {
        var step2APIService = step2APIServiceDependency
        if (typeof step2APIService == 'undefined') {
            step2APIService = Step2APIService
        }

        commit(types.DIAGNOSTIC_REQUEST_UNDERWAY, true)
        return step2APIService.udpateDiagnosisContent(state.diagnosisId, state.diagnosisContent)
            .then(() => {
                commit(types.DIAGNOSTIC_REQUEST_UNDERWAY, false)
            })
            .catch((error) => {
                commit(types.DIAGNOSTIC_REQUEST_UNDERWAY, false)
                throw error
            })
    }
}

const mutations = {
    [types.DIAGNOSTIC_REQUEST_UNDERWAY] (state, isDiagnosisRequestUnderWay) {
        state.isDiagnosisRequestUnderWay = isDiagnosisRequestUnderWay
    },

    [types.DIAGNOSTIC_CONTENT] (state, content) {
        state.diagnosisContent = content
    },

    [types.DIAGNOSTIC_ID] (state, diagnosisId) {
        state.diagnosisId = diagnosisId
    }
}

export default {
    state,
    getters,
    actions,
    mutations
}