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

        describe('FORM_ERROR_TYPE', function () {

            let state

            beforeEach(function () {
                state = {
                    formErrorType: '',
                    companyData: {name: 'Café Bourgeois', location: 'somewhere', siret: 'siret number'}
                }
            })

            it('updates the formErrorType value', function () {
                mutations.FORM_ERROR_TYPE(state, 'ERROR')
                expect(state.formErrorType).toEqual('ERROR')
            })
            it('clears the company values', function () {
                mutations.FORM_ERROR_TYPE(state, 'ERROR')
                expect(state.companyData).toEqual({})
            })
        })

        describe('SIRET', function () {

            it('updates the siret value', function () {
                const state = {siret: ''}
                mutations.SIRET(state, '48245813000010')
                expect(state.siret).toEqual('48245813000010')
            })
        })

        describe('NAME', function () {

            it('updates the name value', function () {
                const state = {name: ''}
                mutations.NAME(state, 'Octo')
                expect(state.name).toEqual('Octo')
            })
        })

        describe('COUNTY', function () {

            it('updates the county value', function () {
                const state = {county: ''}
                mutations.COUNTY(state, '59')
                expect(state.county).toEqual('59')
            })
        })

        describe('COMPANIES', function () {

            it('updates the companies array', function () {
                const state = {companies: []}
                mutations.COMPANIES(state, ['123'])
                expect(state.companies).toEqual(['123'])
            })
        })

        describe('COMPANY_DATA', function () {

            let state

            beforeEach(function () {
                state = {
                    formErrorType: 'ERROR',
                    companyData: {},
                }
            })

            it('updates the companyData value', function () {
                mutations.COMPANY_DATA(state, {name: 'Café Bourgeois', location: 'somewhere', siret: 'siret number'})
                expect(state.companyData.name).toEqual('Café Bourgeois')
                expect(state.companyData.location).toEqual('somewhere')
                expect(state.companyData.siret).toEqual('siret number')
            })
            it('clears the error value', function () {
                mutations.COMPANY_DATA(state, {name: 'Café Bourgeois', location: 'somewhere'})
                expect(state.formErrorType).toEqual('')
            })
        })
    })

    describe('actions', () => {

        const actions = IndexStore.actions

        const indexAPIServiceMock = {
            fetchCompany: function () {
            }
        }

        var dispatch
        var commit
        var state = {}
        var getters = {}

        let apiServiceContext = function (dispatch, commit, state, getters) {
            return {
                dispatch: dispatch,
                commit: commit,
                state: state,
                getters: getters,
                indexAPIServiceDependency: indexAPIServiceMock
            }
        }

        describe('fetchCompany', function () {

            const positivePromise = Promise.resolve({
                company_name: 'Fun Company',
                facility_location: '59350 Lille'
            })

            beforeEach(function () {
                spyOn(indexAPIServiceMock, 'fetchCompany').and.returnValue(positivePromise)
                commit = jasmine.createSpy()

                state.siret = 'siret number'
            })

            it('returns a promise', function () {
                var promise = actions.fetchCompany(apiServiceContext(dispatch, commit, state, getters))
                expect(typeof promise.then).toBe('function')
            })

            it('calls commit REQUEST_IN_PROGRESS with true at start of action', function () {
                actions.fetchCompany(apiServiceContext(dispatch, commit, state, getters))

                expect(commit.calls.argsFor(0)).toEqual([
                    'REQUEST_IN_PROGRESS',
                    true
                ])
            })

            it('calls IndexAPIService with the siret', async function () {
                await actions.fetchCompany(apiServiceContext(dispatch, commit, state, getters))

                expect(indexAPIServiceMock.fetchCompany.calls.count()).toEqual(1)
                expect(indexAPIServiceMock.fetchCompany.calls.argsFor(0)).toEqual(['siret number'])
            })

            it('calls commit COMPANY_DATA with the company data', async function () {
                await actions.fetchCompany(apiServiceContext(dispatch, commit, state, getters))

                expect(commit.calls.argsFor(1)).toEqual([
                    'COMPANY_DATA',
                    {name: 'Fun Company', location: '59350 Lille', siret: 'siret number'}
                ])
            })

            it('calls commit REQUEST_IN_PROGRESS with false at end of action', async function () {
                await actions.fetchCompany(apiServiceContext(dispatch, commit, state, getters))

                expect(commit.calls.argsFor(2)).toEqual([
                    'REQUEST_IN_PROGRESS',
                    false
                ])
            })
        })
    })
})
