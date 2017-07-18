import ContactAPIService from './contactAPIService'
import * as types from './mutationTypes'

const state = {
    contact: undefined,
    visitId: undefined,
    isContactRequestUnderWay: false
};

const getters = {
};

// actions
const actions = {
    createContact ({ commit, state, contactAPIServiceDependency }, contactData) {
        var conctactAPIService = contactAPIServiceDependency;
        if(typeof conctactAPIService == 'undefined') {
            conctactAPIService = ContactAPIService;
        }

        return conctactAPIService.createContactOnVisit(state.visitId, contactData);
    }
};

// mutations
const mutations = {
    [types.CONTACT_REQUEST_UNDERWAY] (state, { isContactRequestUnderWay }) {
        state.isContactRequestUnderWay = isContactRequestUnderWay;
    },

    [types.CONTACT] (state, { contact }) {
        state.contact = contact;
    },

    [types.VISIT_ID] (state, { visitId }) {
        state.visitId = visitId;
    }
};

export default {
    state,
    getters,
    actions,
    mutations
};