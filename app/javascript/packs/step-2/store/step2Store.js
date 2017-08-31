import Step2APIService from './step2APIService'
import BulkRequestAssistant from '../utils/bulkRequestAssistant'
import * as types from './mutationTypes'

const state = {
    diagnosisContent: '',
    diagnosisId: undefined,
    isRequestInProgress: false,
    questions: []
}

const getters = {
    getQuestionStateById: (state, getters) => (id) => {
        return state.questions.find((question) => {
            return question.id === id
        })
    }
}

const actions = {

    sendDiagnosisContentUpdate({commit, state, step2APIServiceDependency}) {
        var step2APIService = step2APIServiceDependency
        if (typeof step2APIService === 'undefined') {
            step2APIService = Step2APIService
        }

        commit(types.REQUEST_IN_PROGRESS, true)
        return step2APIService.updateDiagnosisContent(state.diagnosisId, state.diagnosisContent)
            .then(() => {
                commit(types.REQUEST_IN_PROGRESS, false)
            })
            .catch((error) => {
                commit(types.REQUEST_IN_PROGRESS, false)
                throw error
            })
    },

    sendDiagnosedNeedsBulkUpdate({commit, state, step2APIServiceDependency}) {
        var step2APIService = step2APIServiceDependency
        if (typeof step2APIService === 'undefined') {
            step2APIService = Step2APIService
        }

        const bulkRequestBody = BulkRequestAssistant.createBody(state.questions)
        if (bulkRequestBody.create.length == 0 &&
            bulkRequestBody.update.length == 0 &&
            bulkRequestBody.delete.length == 0) {
            return Promise.resolve(true)

        } else {
            commit(types.REQUEST_IN_PROGRESS, true)

            return step2APIService.updateDiagnosedNeeds(state.diagnosisId, bulkRequestBody)
                .then(() => {
                    commit(types.REQUEST_IN_PROGRESS, false)
                })
                .catch((error) => {
                    commit(types.REQUEST_IN_PROGRESS, false)
                    throw error
                })
        }
    }
}

const mutations = {
    [types.REQUEST_IN_PROGRESS](state, isRequestInProgress) {
        state.isRequestInProgress = isRequestInProgress
    },

    [types.DIAGNOSIS_CONTENT](state, content) {
        let diagnosis_content = content
        if (!diagnosis_content) {
            diagnosis_content = ''
        }
        state.diagnosisContent = diagnosis_content
    },

    [types.DIAGNOSIS_ID](state, diagnosisId) {
        state.diagnosisId = diagnosisId
    },

    [types.QUESTION_ID](state, {id, questionId}) {
        const questionAndIndex = getOrCreateQuestionEnumerated(state, id)
        questionAndIndex.newQuestion.questionId = questionId
        state.questions.splice(questionAndIndex.index, 1, questionAndIndex.newQuestion)
    },

    [types.QUESTION_SELECTED](state, {id, isSelected}) {
        const questionAndIndex = getOrCreateQuestionEnumerated(state, id)
        questionAndIndex.newQuestion.isSelected = isSelected

        state.questions.splice(questionAndIndex.index, 1, questionAndIndex.newQuestion)
    },

    [types.QUESTION_CONTENT](state, {id, content}) {
        const questionAndIndex = getOrCreateQuestionEnumerated(state, id)
        questionAndIndex.newQuestion.content = content
        state.questions.splice(questionAndIndex.index, 1, questionAndIndex.newQuestion)
    },

    [types.QUESTION_LABEL](state, {id, questionLabel}) {
        const questionAndIndex = getOrCreateQuestionEnumerated(state, id)
        questionAndIndex.newQuestion.questionLabel = questionLabel
        state.questions.splice(questionAndIndex.index, 1, questionAndIndex.newQuestion)
    },

    [types.DIAGNOSED_NEED_ID](state, {id, diagnosedNeedId}) {
        const questionAndIndex = getOrCreateQuestionEnumerated(state, id)
        questionAndIndex.newQuestion.diagnosedNeedId = diagnosedNeedId
        state.questions.splice(questionAndIndex.index, 1, questionAndIndex.newQuestion)
    }
}

const getOrCreateQuestionEnumerated = function (state, id) {
    let question = state.questions.find((question) => {
        return question.id === id
    })
    if (!question) {
        question = {}
        state.questions.push(question)
        question.id = id
    }
    // To trigger vue updates, one must use splice
    const index = state.questions.indexOf(question)
    const newQuestion = JSON.parse(JSON.stringify(question))
    return {newQuestion: newQuestion, index: index}
}

export default {
    state,
    getters,
    actions,
    mutations
}
