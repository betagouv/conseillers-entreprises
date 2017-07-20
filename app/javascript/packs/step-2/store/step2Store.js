import ContactAPIService from './step2APIService'
import * as types from './mutationTypes'

const state = {
    diagnosisContent: "",
    diagnosisId: undefined,
    isDiagnosisRequestUnderWay: false
};

const getters = {
};

const actions = {
    // getContact ({ commit, state, contactAPIServiceDependency }) {
    //     var contactAPIService = contactAPIServiceDependency;
    //     if(typeof contactAPIService == 'undefined') {
    //         contactAPIService = ContactAPIService;
    //     }
    //
    //     commit(types.CONTACT_REQUEST_UNDERWAY, {isContactRequestUnderWay: true});
    //     return contactAPIService.getContacts(state.visitId)
    //         .then( (contacts) => {
    //             commit(types.CONTACT, {contact: contacts[0]});
    //             commit(types.CONTACT_REQUEST_UNDERWAY, {isContactRequestUnderWay: false});
    //         });
    // }
};

const mutations = {
    [types.DIAGNOSTIC_REQUEST_UNDERWAY] (state, isDiagnosisRequestUnderWay) {
        state.isDiagnosisRequestUnderWay = isDiagnosisRequestUnderWay;
    },

    [types.DIAGNOSTIC_CONTENT] (state, content) {
        state.diagnosisContent = content;
    },

    [types.DIAGNOSTIC_ID] (state, diagnosisId) {
        state.diagnosisId = diagnosisId;
    }
};

export default {
    state,
    getters,
    actions,
    mutations
};