import SearchStore from '../../../../packs/common/companySearch/store/searchStore'

// for the async function to work
require('babel-core/register')
// TODO : WHY IS babel-polyfill needed. And why does it go to other files...
require('babel-polyfill')

describe('SearchStore', () => {
  describe('actions', () => {
    const actions = SearchStore.actions

    const searchAPIServiceMock = {
      fetchCompanyBySiret: function () {
      },
      fetchCompanyBySiren: function () {
      },
      fetchCompaniesByName: function () {
      }
    }

    var dispatch
    var commit
    var state = {}
    var getters = {}

    const apiServiceContext = function (dispatch, commit, state, getters) {
      return {
        dispatch: dispatch,
        commit: commit,
        state: state,
        getters: getters,
        searchAPIServiceDependency: searchAPIServiceMock
      }
    }

    describe('fetchCompanyBySiret', function () {
      const positivePromise = Promise.resolve({
        company_name: 'Fun Company',
        facility_location: '59350 Lille'
      })

      beforeEach(function () {
        spyOn(searchAPIServiceMock, 'fetchCompanyBySiret').and.returnValue(positivePromise)
        commit = jasmine.createSpy()

        state.siret = 'siret number'
      })

      it('returns a promise', function () {
        var promise = actions.fetchCompanyBySiret(apiServiceContext(dispatch, commit, state, getters))
        expect(typeof promise.then).toBe('function')
      })

      it('calls commit REQUEST_IN_PROGRESS with true at start of action', function () {
        actions.fetchCompanyBySiret(apiServiceContext(dispatch, commit, state, getters))

        expect(commit.calls.argsFor(0)).toEqual([
          'REQUEST_IN_PROGRESS',
          true
        ])
      })

      it('calls IndexAPIService with the siret', async function () {
        await actions.fetchCompanyBySiret(apiServiceContext(dispatch, commit, state, getters))

        expect(searchAPIServiceMock.fetchCompanyBySiret.calls.count()).toEqual(1)
        expect(searchAPIServiceMock.fetchCompanyBySiret.calls.argsFor(0)).toEqual(['siret number'])
      })

      it('calls commit COMPANY_DATA with the company data', async function () {
        await actions.fetchCompanyBySiret(apiServiceContext(dispatch, commit, state, getters))

        expect(commit.calls.argsFor(1)).toEqual([
          'COMPANY_DATA',
          { name: 'Fun Company', location: '59350 Lille', siret: 'siret number' }
        ])
      })

      it('calls commit REQUEST_IN_PROGRESS with false at end of action', async function () {
        await actions.fetchCompanyBySiret(apiServiceContext(dispatch, commit, state, getters))

        expect(commit.calls.argsFor(2)).toEqual([
          'REQUEST_IN_PROGRESS',
          false
        ])
      })
    })

    describe('fetchCompanyBySiren', function () {
      const positivePromise = Promise.resolve({
        company_name: 'Fun Company',
        facility_location: '59350 Lille',
        siret: '12345678901234'
      })

      beforeEach(function () {
        spyOn(searchAPIServiceMock, 'fetchCompanyBySiren').and.returnValue(positivePromise)
        commit = jasmine.createSpy()

        state.siren = 'siren number'
      })

      it('returns a promise', function () {
        var promise = actions.fetchCompanyBySiren(apiServiceContext(dispatch, commit, state, getters))
        expect(typeof promise.then).toBe('function')
      })

      it('calls commit REQUEST_IN_PROGRESS with true at start of action', function () {
        actions.fetchCompanyBySiren(apiServiceContext(dispatch, commit, state, getters))

        expect(commit.calls.argsFor(0)).toEqual([
          'REQUEST_IN_PROGRESS',
          true
        ])
      })

      it('calls IndexAPIService with the siren', async function () {
        await actions.fetchCompanyBySiren(apiServiceContext(dispatch, commit, state, getters))

        expect(searchAPIServiceMock.fetchCompanyBySiren.calls.count()).toEqual(1)
        expect(searchAPIServiceMock.fetchCompanyBySiren.calls.argsFor(0)).toEqual(['siren number'])
      })

      it('calls commit COMPANY_DATA with the company data', async function () {
        await actions.fetchCompanyBySiren(apiServiceContext(dispatch, commit, state, getters))

        expect(commit.calls.argsFor(1)).toEqual([
          'COMPANY_DATA',
          { name: 'Fun Company', location: '59350 Lille', siret: '12345678901234' }
        ])
      })

      it('calls commit REQUEST_IN_PROGRESS with false at end of action', async function () {
        await actions.fetchCompanyBySiren(apiServiceContext(dispatch, commit, state, getters))

        expect(commit.calls.argsFor(2)).toEqual([
          'REQUEST_IN_PROGRESS',
          false
        ])
      })
    })

    describe('fetchCompaniesByName', function () {
      const positivePromise = Promise.resolve({
        companies: [{ siren: '123456789', name: 'Octo', location: '59123 Meubauge' }]
      })
      const searchObject = {
        name: 'Octo',
        county: '59'
      }

      beforeEach(function () {
        spyOn(searchAPIServiceMock, 'fetchCompaniesByName').and.returnValue(positivePromise)
        commit = jasmine.createSpy()
      })

      it('returns a promise', function () {
        const promise = actions.fetchCompaniesByName(apiServiceContext(dispatch, commit, state, getters), searchObject)
        expect(typeof promise.then).toBe('function')
      })

      it('calls commit REQUEST_IN_PROGRESS with true at start of action', function () {
        actions.fetchCompaniesByName(apiServiceContext(dispatch, commit, state, getters), searchObject)

        expect(commit.calls.argsFor(0)).toEqual([
          'REQUEST_IN_PROGRESS',
          true
        ])
      })

      it('calls IndexAPIService with company name and county', async function () {
        await actions.fetchCompaniesByName(apiServiceContext(dispatch, commit, state, getters), searchObject)

        expect(searchAPIServiceMock.fetchCompaniesByName.calls.count()).toEqual(1)
        expect(searchAPIServiceMock.fetchCompaniesByName.calls.argsFor(0)).toEqual([{ name: 'Octo', county: '59' }])
      })

      it('calls commit COMPANIES with the companies data', async function () {
        await actions.fetchCompaniesByName(apiServiceContext(dispatch, commit, state, getters), searchObject)

        expect(commit.calls.argsFor(1)).toEqual([
          'COMPANIES',
          [{ siren: '123456789', name: 'Octo', location: '59123 Meubauge' }]
        ])
      })

      it('calls commit REQUEST_IN_PROGRESS with false at end of action', async function () {
        await actions.fetchCompaniesByName(apiServiceContext(dispatch, commit, state, getters), searchObject)

        expect(commit.calls.argsFor(2)).toEqual([
          'REQUEST_IN_PROGRESS',
          false
        ])
      })
    })
  })

  describe('mutations', () => {
    const mutations = SearchStore.mutations

    describe('REQUEST_IN_PROGRESS', function () {
      it('updates the isRequestInProgress value', function () {
        const state = { isRequestInProgress: undefined }
        mutations.REQUEST_IN_PROGRESS(state, true)
        expect(state.isRequestInProgress).toBeTruthy()
      })
    })

    describe('FORM_ERROR_TYPE', function () {
      let state

      beforeEach(function () {
        state = {
          formErrorType: '',
          companyData: { name: 'Café Bourgeois', location: 'somewhere', siret: 'siret number' }
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
        const state = { siret: '' }
        mutations.SIRET(state, '48245813000010')
        expect(state.siret).toEqual('48245813000010')
      })
    })

    describe('COMPANIES', function () {
      it('updates the companies array', function () {
        const state = { companies: [] }
        mutations.COMPANIES(state, ['123'])
        expect(state.companies).toEqual(['123'])
      })
    })

    describe('COMPANY_DATA', function () {
      let state

      beforeEach(function () {
        state = {
          formErrorType: 'ERROR',
          companyData: {}
        }
      })

      it('updates the companyData value', function () {
        mutations.COMPANY_DATA(state, { name: 'Café Bourgeois', location: 'somewhere', siret: 'siret number' })
        expect(state.companyData.name).toEqual('Café Bourgeois')
        expect(state.companyData.location).toEqual('somewhere')
        expect(state.companyData.siret).toEqual('siret number')
      })
      it('clears the error value', function () {
        mutations.COMPANY_DATA(state, { name: 'Café Bourgeois', location: 'somewhere' })
        expect(state.formErrorType).toEqual('')
      })
    })
  })
})
