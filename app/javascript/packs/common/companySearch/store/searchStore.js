import SearchAPIService from '../utils/searchAPIService'
import * as types from './searchMutationTypes'
import * as errors from '../utils/searchErrorTypes'

const state = {
  isRequestInProgress: false,
  formErrorType: '',
  companyData: {},
  siret: '',
  companies: []
}

const getters = {}

const actions = {
  fetchCompanyBySiret ({ commit, state, searchAPIServiceDependency }, { siret }) {
    let searchAPIService = searchAPIServiceDependency
    if (typeof searchAPIService === 'undefined') {
      searchAPIService = SearchAPIService
    }

    commit(types.REQUEST_IN_PROGRESS, true)
    return searchAPIService.fetchCompanyBySiret(siret)
      .then((data) => {
        commit(types.COMPANY_DATA, {
          name: data.company_name,
          location: data.facility_location,
          siret: siret
        })
      })
      .catch(() => {
        commit(types.FORM_ERROR_TYPE, errors.NOT_FOUND_ERROR)
      })
      .then(() => {
        commit(types.REQUEST_IN_PROGRESS, false)
      })
  },

  fetchCompanyBySiren ({ commit, state, searchAPIServiceDependency }, { siren }) {
    let searchAPIService = searchAPIServiceDependency
    if (typeof searchAPIService === 'undefined') {
      searchAPIService = SearchAPIService
    }

    commit(types.REQUEST_IN_PROGRESS, true)
    return searchAPIService.fetchCompanyBySiren(siren)
      .then((data) => {
        commit(types.COMPANY_DATA, {
          name: data.company_name,
          location: data.facility_location,
          siret: data.siret
        })
      })
      .catch(() => {
        commit(types.FORM_ERROR_TYPE, errors.NOT_FOUND_ERROR)
      })
      .then(() => {
        commit(types.REQUEST_IN_PROGRESS, false)
      })
  },

  fetchCompaniesByName ({ commit, state, searchAPIServiceDependency }, { name, county }) {
    let searchAPIService = searchAPIServiceDependency
    if (typeof searchAPIService === 'undefined') {
      searchAPIService = SearchAPIService
    }

    commit(types.REQUEST_IN_PROGRESS, true)
    return searchAPIService.fetchCompaniesByName({ name: name, county: county })
      .then((data) => {
        commit(types.COMPANIES, data.companies)
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
  [types.REQUEST_IN_PROGRESS] (state, isRequestInProgress) {
    state.isRequestInProgress = isRequestInProgress
  },

  [types.FORM_ERROR_TYPE] (state, formErrorType) {
    state.formErrorType = formErrorType
    state.companyData = {}
  },

  [types.COMPANIES] (state, companies) {
    state.companies = companies
  },

  [types.COMPANY_DATA] (state, { name, location, siret }) {
    state.companyData = { name: name, location: location, siret: siret }
    state.formErrorType = ''
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}
