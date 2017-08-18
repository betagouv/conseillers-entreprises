import IndexStore from '../../../packs/index/store/indexStore'

//for the async function to work
require('babel-core/register')

describe('IndexStore', () => {

    describe('getters', () => {

        const getters = IndexStore.getters

    })

    describe('mutations', () => {

        const mutations = IndexStore.mutations

        describe('REQUEST_IN_PROGRESS', function () {

            it('updates the isRequestInProgress value', function () {
                const state = {isRequestInProgress: undefined}
                mutations.REQUEST_IN_PROGRESS(state, true)
                expect(state.isRequestInProgress).toBeTruthy()
            })
        })

        describe('FORM_ERROR_MESSAGE', function () {

            it('updates the showFormErrorMessage value', function () {
                const state = {showFormErrorMessage: undefined}
                mutations.FORM_ERROR_MESSAGE(state, true)
                expect(state.showFormErrorMessage).toBeTruthy()
            })
        })

        describe('SIRET', function () {

            it('updates the siret value', function () {
                const state = {siret: ''}
                mutations.SIRET(state, '48245813000010')
                expect(state.siret).toEqual('48245813000010')
            })
        })
    })

    describe('actions', () => {

        const actions = IndexStore.actions

    })
})
