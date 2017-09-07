import IndexAPIService from '../utils/indexAPIService'
import * as types from './indexMutationTypes'
import * as errors from '../utils/indexErrorTypes'

const state = {
    isRequestInProgress: false,
    formErrorType: '',
    companyData: {},
    siret: '',
    name: '',
    county: '',
    companies: []
}

const getters = {}

const actions = {
    fetchCompany({commit, state, indexAPIServiceDependency}) {
        let indexAPIService = indexAPIServiceDependency
        if (typeof indexAPIService === 'undefined') {
            indexAPIService = IndexAPIService
        }

        commit(types.REQUEST_IN_PROGRESS, true)
        return indexAPIService.fetchCompany(state.siret)
            .then((data) => {
                commit(types.COMPANY_DATA, {
                    name: data.company_name,
                    location: data.facility_location,
                    siret: state.siret
                })
            })
            .catch(() => {
                commit(types.FORM_ERROR_TYPE, errors.NOT_FOUND_ERROR)
            })
            .then(() => {
                commit(types.REQUEST_IN_PROGRESS, false)
            })
    },

    fetchCompaniesByName({commit, state, indexAPIServiceDependency}) {
        let indexAPIService = indexAPIServiceDependency
        if (typeof indexAPIService === 'undefined') {
            indexAPIService = IndexAPIService
        }

        commit(types.REQUEST_IN_PROGRESS, true)
        return indexAPIService.fetchCompaniesByName(state.name, state.county)
            .then((data) => {
                commit(types.COMPANIES, data)
            })
            .catch(() => {
                commit(types.FORM_ERROR_TYPE, errors.NOT_FOUND_ERROR)
            })
            .then(() => {
                commit(types.REQUEST_IN_PROGRESS, false)
            })
    }
}

const mutations = {
    [types.REQUEST_IN_PROGRESS](state, isRequestInProgress) {
        state.isRequestInProgress = isRequestInProgress
    },

    [types.FORM_ERROR_TYPE](state, formErrorType) {
        state.formErrorType = formErrorType
        state.companyData = {}
    },

    [types.SIRET](state, siret) {
        state.siret = siret
    },

    [types.NAME](state, name) {
        state.name = name
    },

    [types.COUNTY](state, county) {
        state.county = county
    },

    [types.COMPANIES](state, companies) {
        state.companies = companies
    },

    [types.COMPANY_DATA](state, {name, location, siret}) {
        state.companyData = {name: name, location: location, siret: siret}
        state.formErrorType = ''
    }
}

export default {
    state,
    getters,
    actions,
    mutations
}
