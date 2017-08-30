import axios from 'axios'
import Step3Store from '../../../packs/step-3/store/step3Store'

//for the async function to work
require('babel-core/register')

describe('step3Store', () => {

    describe('getters', () => {

        const getters = Step3Store.getters
        let state

        beforeEach(() => {
            state = {
                isInitialLoadingInProgress: false,
                isRequestInProgress: false,
                name: '',
                job: '',
                email: '',
                phoneNumber: '',
                visitDate: '',
                visitId: undefined
            }
        })

        describe('isNameCompleted', function () {

            it('returns false when empty', function () {
                state.name = ''
                expect(getters.isNameCompleted(state)).toBeFalsy()
            })

            it('returns true when not empty', function () {
                state.name = 'Jacques'
                expect(getters.isNameCompleted(state)).toBeTruthy()
            })
        })

        describe('isJobCompleted', function () {

            it('returns false when empty', function () {
                state.job = ''
                expect(getters.isJobCompleted(state)).toBeFalsy()
            })

            it('returns true when not empty', function () {
                state.job = 'not empty'
                expect(getters.isJobCompleted(state)).toBeTruthy()
            })
        })

        describe('areContactDetailsCompleted', function () {

            it('returns false when both are empty', function () {
                state.email = ''
                state.phoneNumber = ''
                expect(getters.areContactDetailsCompleted(state)).toBeFalsy()
            })

            it('returns true when email is not empty', function () {
                state.email = 'not empty'
                state.phoneNumber = ''
                expect(getters.areContactDetailsCompleted(state)).toBeTruthy()
            })

            it('returns true when phoneNumber is not empty', function () {
                state.email = ''
                state.phoneNumber = 'not empty'
                expect(getters.areContactDetailsCompleted(state)).toBeTruthy()
            })

            it('returns true when both are not empty', function () {
                state.email = 'not empty'
                state.phoneNumber = 'not empty'
                expect(getters.areContactDetailsCompleted(state)).toBeTruthy()
            })
        })

        describe('isFormCompleted', function () {

            it('returns false when at least one of the completion getters is false', function () {
                getters.isNameCompleted = false
                getters.isJobCompleted = true
                getters.areContactDetailsCompleted = true

                expect(getters.isFormCompleted(state, getters)).toBeFalsy()
            })

            it('returns true when all of the completion getters are true', function () {
                getters.isNameCompleted = true
                getters.isJobCompleted = true
                getters.areContactDetailsCompleted = true

                expect(getters.isFormCompleted(state, getters)).toBeTruthy()
            })
        })

        describe('isDateCompleted', function () {

            it('returns false when empty', function () {
                state.visitDate = ''
                expect(getters.isDateCompleted(state)).toBeFalsy()
            })

            it('returns true when not empty', function () {
                state.visitDate = '10/20/30'
                expect(getters.isDateCompleted(state)).toBeTruthy()
            })
        })

        describe('areModificationDisabled', function () {

            it('returns false when isRequestInProgress and isInitialLoadingInProgress false', function () {
                state.isInitialLoadingInProgress = false
                state.isRequestInProgress = false
                expect(getters.areModificationDisabled(state)).toBeFalsy()
            })

            it('returns true when isRequestInProgress is true', function () {
                state.isRequestInProgress = true
                expect(getters.areModificationDisabled(state)).toBeTruthy()
            })

            it('returns true when isInitialLoadingInProgress is true', function () {
                state.isInitialLoadingInProgress = true
                expect(getters.areModificationDisabled(state)).toBeTruthy()
            })
        })
    })

    describe('mutations', () => {

        const mutations = Step3Store.mutations

        describe('INITIAL_LOADING_IN_PROGRESS', function () {

            it('updates the isInitialLoadingInProgress', function () {
                const state = {isInitialLoadingInProgress: false}
                mutations.INITIAL_LOADING_IN_PROGRESS(state, true)
                expect(state.isInitialLoadingInProgress).toBeTruthy()
            })
        })

        describe('REQUEST_IN_PROGRESS', function () {

            it('updates the isRequestInProgress', function () {
                const state = {isRequestInProgress: false}
                mutations.REQUEST_IN_PROGRESS(state, true)
                expect(state.isRequestInProgress).toBeTruthy()
            })
        })

        describe('CONTACT_NAME', function () {

            it('updates the name', function () {
                const state = {name: 'whatever'}
                mutations.CONTACT_NAME(state, 'Jean-Jacques')
                expect(state.name).toEqual('Jean-Jacques')
            })
        })

        describe('CONTACT_JOB', function () {

            it('updates the name', function () {
                const state = {job: 'jobless'}
                mutations.CONTACT_JOB(state, 'random job')
                expect(state.job).toEqual('random job')
            })
        })

        describe('CONTACT_EMAIL', function () {

            it('updates the name', function () {
                const state = {email: 'no email'}
                mutations.CONTACT_EMAIL(state, 'email@email.com')
                expect(state.email).toEqual('email@email.com')
            })
        })

        describe('CONTACT_PHONE_NUMBER', function () {

            it('updates the name', function () {
                const state = {phoneNumber: 'no number'}
                mutations.CONTACT_PHONE_NUMBER(state, '060606060606')
                expect(state.phoneNumber).toEqual('060606060606')
            })
        })

        describe('VISIT_DATE', function () {

            it('updates the date', function () {
                const state = {visitDate: 'no date'}
                mutations.VISIT_DATE(state, '01/04/2029')
                expect(state.visitDate).toEqual('01/04/2029')
            })
        })

        describe('VISIT_ID', function () {

            it('updates the visit id', function () {
                const state = {visitId: undefined}
                mutations.VISIT_ID(state, '2029')
                expect(state.visitId).toEqual('2029')
            })
        })

        describe('FORM_FIELDS_ERROR', function () {

            it('updates the showFormFieldsError boolean', function () {
                const state = {showFormFieldErrors: false}
                mutations.FORM_FIELDS_ERROR(state, true)
                expect(state.showFormFieldErrors).toBeTruthy()
            })
        })

        describe('FORM_ERROR_MESSAGE', function () {

            it('updates the date', function () {
                const state = {showFormErrorMessage: false}
                mutations.FORM_ERROR_MESSAGE(state, true)
                expect(state.showFormErrorMessage).toBeTruthy()
            })
        })

        describe('DIAGNOSIS_ID', function () {

            it('updates the diagnosisID', function () {
                const state = {diagnosisId: undefined}
                mutations.DIAGNOSIS_ID(state, '12')
                expect(state.diagnosisId).toEqual('12')
            })
        })

        describe('CONTACT_ID', function () {

            it('updates the contactId', function () {
                const state = {contactId: undefined}
                mutations.CONTACT_ID(state, 12)
                expect(state.contactId).toEqual(12)
            })
        })
    })

    describe('actions', () => {

        const actions = Step3Store.actions

        const step3StoreAPIServiceMock = {
            updateVisitDate: function () {
            },
            getVisitFromId: function () {
            },
            createContactForVisit: function () {
            },
            getContactFromId: function () {
            }
        }

        var commit
        var dispatch
        var getters = {}
        var state = {}

        let apiServiceContext = function (dispatch, commit, state, getters) {
            return {
                dispatch: dispatch,
                commit: commit,
                state: state,
                getters: getters,
                step3APIServiceDependency: step3StoreAPIServiceMock
            }
        }

        describe('getInitialData', function () {

            let dispatchFunction = function (withContactId) {
                return (dispatchedTo) => {
                    let data = {}
                    if(dispatchedTo == 'getVisitData') {
                        data = {
                            visit_id: 1,
                            happened_at: '2017-08-29',
                            visitee_id: withContactId ? 2 : undefined
                        }
                    } else {
                        data = {
                            id: 2,
                            full_name: 'Monsieur Daron',
                            email: 'daron@patron.com',
                            phone_number: '',
                            role: 'Patron',
                            company_id: 1
                        }
                    }
                    return Promise.resolve(data)
                }
            }

            describe('when there is a contact to laod', function () {

                beforeEach(function () {
                    state.contactId = 123
                    commit = jasmine.createSpy()
                    dispatch = jasmine.createSpy().and.callFake(dispatchFunction(true))
                })

                it('returns a promise', function () {
                    var promise = actions.getInitialData(apiServiceContext(dispatch, commit, state, getters))
                    expect(typeof promise.then).toBe('function')
                })

                it('calls commit INITIAL_LOADING_IN_PROGRESS with true at start of action', function () {
                    actions.getInitialData(apiServiceContext(dispatch, commit, state, getters))

                    expect(commit.calls.argsFor(0)).toEqual([
                        'INITIAL_LOADING_IN_PROGRESS',
                        true
                    ])
                })

                it('calls dispatch getVisitData', async function () {
                    await actions.getInitialData(apiServiceContext(dispatch, commit, state, getters))

                    expect(dispatch.calls.argsFor(0)).toEqual(['getVisitData'])
                })

                it('calls commit VISIT_DATE and CONTACT_ID with value received', async function () {
                    await actions.getInitialData(apiServiceContext(dispatch, commit, state, getters))

                    expect(commit.calls.argsFor(1)).toEqual([
                        'VISIT_DATE',
                        '2017-08-29'
                    ])
                    expect(commit.calls.argsFor(2)).toEqual([
                        'CONTACT_ID',
                        2
                    ])
                })

                it('calls dispatch getContactData', async function () {
                    await actions.getInitialData(apiServiceContext(dispatch, commit, state, getters))

                    expect(dispatch.calls.count()).toEqual(2)
                    expect(dispatch.calls.argsFor(1)).toEqual(['getContactData'])
                })

                it('calls commit for contact properties with value received', async function () {
                    await actions.getInitialData(apiServiceContext(dispatch, commit, state, getters))

                    expect(commit.calls.argsFor(3)).toEqual([
                        'CONTACT_NAME',
                        'Monsieur Daron'
                    ])
                    expect(commit.calls.argsFor(4)).toEqual([
                        'CONTACT_JOB',
                        'Patron'
                    ])
                    expect(commit.calls.argsFor(5)).toEqual([
                        'CONTACT_EMAIL',
                        'daron@patron.com'
                    ])
                    expect(commit.calls.argsFor(6)).toEqual([
                        'CONTACT_PHONE_NUMBER',
                        ''
                    ])
                })

                it('calls commit INITIAL_LOADING_IN_PROGRESS with false at end of action', async function () {
                    await actions.getInitialData(apiServiceContext(dispatch, commit, state, getters))

                    expect(commit.calls.count()).toEqual(8)
                    expect(commit.calls.argsFor(7)).toEqual([
                        'INITIAL_LOADING_IN_PROGRESS',
                        false
                    ])
                })
            })

            describe('when there is no contact to laod', function () {

                beforeEach(function () {
                    state.contactId = undefined
                    commit = jasmine.createSpy()
                    dispatch = jasmine.createSpy().and.callFake(dispatchFunction(false))
                })

                it('returns a promise', function () {
                    var promise = actions.getInitialData(apiServiceContext(dispatch, commit, state, getters))
                    expect(typeof promise.then).toBe('function')
                })

                it('calls commit INITIAL_LOADING_IN_PROGRESS with true at start of action', function () {
                    actions.getInitialData(apiServiceContext(dispatch, commit, state, getters))

                    expect(commit.calls.argsFor(0)).toEqual([
                        'INITIAL_LOADING_IN_PROGRESS',
                        true
                    ])
                })

                it('calls dispatch getVisitData', async function () {
                    await actions.getInitialData(apiServiceContext(dispatch, commit, state, getters))

                    expect(dispatch.calls.argsFor(0)).toEqual(['getVisitData'])
                })

                it('calls commit VISIT_DATE and CONTACT_ID with value received', async function () {
                    await actions.getInitialData(apiServiceContext(dispatch, commit, state, getters))

                    expect(commit.calls.argsFor(1)).toEqual([
                        'VISIT_DATE',
                        '2017-08-29'
                    ])
                    expect(commit.calls.argsFor(2)).toEqual([
                        'CONTACT_ID',
                        undefined
                    ])
                })

                it('does not calls dispatch getContactData', async function () {
                    await actions.getInitialData(apiServiceContext(dispatch, commit, state, getters))

                    expect(dispatch.calls.count()).toEqual(1)
                })

                it('calls commit INITIAL_LOADING_IN_PROGRESS with false at end of action', async function () {
                    await actions.getInitialData(apiServiceContext(dispatch, commit, state, getters))

                    expect(commit.calls.count()).toEqual(4)
                    expect(commit.calls.argsFor(3)).toEqual([
                        'INITIAL_LOADING_IN_PROGRESS',
                        false
                    ])
                })
            })
        })

        describe('launchNextStep', function () {

            let dispatchFunction = function (value) {
                return (dispatchedTo) => {
                    return Promise.resolve(value)
                }
            }

            describe('when api call is a success', function () {

                beforeEach(function () {
                    commit = jasmine.createSpy()
                    dispatch = jasmine.createSpy().and.callFake(dispatchFunction(true))
                })

                it('returns a promise', function () {
                    var promise = actions.launchNextStep(apiServiceContext(dispatch, commit, state, getters))
                    expect(typeof promise.then).toBe('function')
                })

                it('calls commit REQUEST_IN_PROGRESS with true at start of action', function () {
                    actions.launchNextStep(apiServiceContext(dispatch, commit, state, getters))

                    expect(commit.calls.argsFor(0)).toEqual([
                        'REQUEST_IN_PROGRESS',
                        true
                    ])
                })

                it('calls commit FORM_FIELDS_ERROR with true at start of action', function () {
                    actions.launchNextStep(apiServiceContext(dispatch, commit, state, getters))

                    expect(commit.calls.argsFor(1)).toEqual([
                        'FORM_FIELDS_ERROR',
                        true
                    ])
                })

                it('calls commit FORM_ERROR_MESSAGE with false at start of action', function () {
                    actions.launchNextStep(apiServiceContext(dispatch, commit, state, getters))

                    expect(commit.calls.argsFor(2)).toEqual([
                        'FORM_ERROR_MESSAGE',
                        false
                    ])
                })

                it('calls dispatch checkFormCompletion', async function () {
                    await actions.launchNextStep(apiServiceContext(dispatch, commit, state, getters))

                    expect(dispatch.calls.argsFor(0)).toEqual(['checkFormCompletion'])
                })

                it('calls dispatch updateVisitData', async function () {
                    await actions.launchNextStep(apiServiceContext(dispatch, commit, state, getters))

                    expect(dispatch.calls.argsFor(1)).toEqual(['updateVisitDate'])
                })

                it('calls dispatch createContact', async function () {
                    await actions.launchNextStep(apiServiceContext(dispatch, commit, state, getters))

                    expect(dispatch.calls.count()).toEqual(3)
                    expect(dispatch.calls.argsFor(2)).toEqual(['createContact'])
                })

                it('calls commit REQUEST_IN_PROGRESS with false at end of action', async function () {
                    await actions.launchNextStep(apiServiceContext(dispatch, commit, state, getters))

                    expect(commit.calls.count()).toEqual(4)
                    expect(commit.calls.argsFor(3)).toEqual([
                        'REQUEST_IN_PROGRESS',
                        false
                    ])
                })
            })
        })

        describe('checkFormCompletion', function () {

            describe('when form is completed', function () {

                beforeEach(function () {
                    getters.isFormCompleted = true
                    getters.isDateCompleted = true
                })

                it('returns a promise', function () {
                    var promise = actions.checkFormCompletion(apiServiceContext(dispatch, commit, state, getters))
                    expect(typeof promise.then).toBe('function')
                })

                it('returns true', async function () {
                    var promiseResult
                    var promiseError
                    await actions.checkFormCompletion(apiServiceContext(dispatch, commit, state, getters))
                        .then((result) => {
                            promiseResult = result
                        })
                        .catch((error) => {
                            promiseError = error
                        })
                    expect(promiseResult).toBeTruthy()
                    expect(promiseError).toBeUndefined()
                })
            })

            describe('when form is not completed', function () {

                beforeEach(function () {
                    getters.isFormCompleted = true
                    getters.isDateCompleted = false
                })

                it('returns a promise', function () {
                    var promise = actions.checkFormCompletion(apiServiceContext(dispatch, commit, state, getters))
                    expect(typeof promise.then).toBe('function')
                })

                it('returns an error', async function () {
                    const expectedError = new Error('the form is not completed')
                    var promiseResult
                    var promiseError
                    await actions.checkFormCompletion(apiServiceContext(dispatch, commit, state, getters))
                        .then((result) => {
                            promiseResult = result
                        })
                        .catch((error) => {
                            promiseError = error
                        })
                    expect(promiseResult).toBeUndefined()
                    expect(promiseError).toEqual(expectedError)
                })
            })
        })

        describe('updateVisitDate', function () {

            const positivePromise = Promise.resolve(true)

            beforeEach(function () {
                spyOn(step3StoreAPIServiceMock, 'updateVisitDate').and.returnValue(positivePromise)
                commit = jasmine.createSpy()

                state.visitDate = '2014-08-01'
                state.visitId = 12
            })

            it('returns a promise', function () {
                var promise = actions.updateVisitDate(apiServiceContext(dispatch, commit, state, getters))
                expect(typeof promise.then).toBe('function')
            })

            it('calls Step3APIService with the visitId and the visitDate', async function () {
                await actions.updateVisitDate(apiServiceContext(dispatch, commit, state, getters))

                expect(step3StoreAPIServiceMock.updateVisitDate.calls.count()).toEqual(1)
                expect(step3StoreAPIServiceMock.updateVisitDate.calls.argsFor(0)).toEqual([12, '2014-08-01'])
            })
        })

        describe('getVisitData', function () {

            const positivePromise = Promise.resolve(true)

            beforeEach(function () {
                spyOn(step3StoreAPIServiceMock, 'getVisitFromId').and.returnValue(positivePromise)
                commit = jasmine.createSpy()

                state.visitId = 12
            })

            it('returns a promise', function () {
                var promise = actions.getVisitData(apiServiceContext(dispatch, commit, state, getters))
                expect(typeof promise.then).toBe('function')
            })

            it('calls Step3APIService with the visitId', async function () {
                await actions.getVisitData(apiServiceContext(dispatch, commit, state, getters))

                expect(step3StoreAPIServiceMock.getVisitFromId.calls.count()).toEqual(1)
                expect(step3StoreAPIServiceMock.getVisitFromId.calls.argsFor(0)).toEqual([12])
            })
        })

        describe('createContactForVisit', function () {

            const contactData = {
                full_name: 'Monsieur Daron',
                email: 'daron@patron.com',
                phone_number: '0102030405',
                role: 'Patron'
            }
            const positivePromise = Promise.resolve(true)

            beforeEach(function () {
                spyOn(step3StoreAPIServiceMock, 'createContactForVisit').and.returnValue(positivePromise)
                commit = jasmine.createSpy()

                state.name = 'Monsieur Daron'
                state.email = 'daron@patron.com'
                state.job = 'Patron'
                state.phoneNumber = '0102030405'
                state.visitId = 12
            })

            it('returns a promise', function () {
                var promise = actions.createContact(apiServiceContext(dispatch, commit, state, getters))
                expect(typeof promise.then).toBe('function')
            })

            it('calls contactAPIService with the diagnosisId and the diagnosedNeeds', async function () {
                await actions.createContact(apiServiceContext(dispatch, commit, state, getters))

                expect(step3StoreAPIServiceMock.createContactForVisit.calls.count()).toEqual(1)
                expect(step3StoreAPIServiceMock.createContactForVisit.calls.argsFor(0)).toEqual([12, contactData])
            })
        })

        describe('getContactData', function () {

            const positivePromise = Promise.resolve(true)

            beforeEach(function () {
                spyOn(step3StoreAPIServiceMock, 'getContactFromId').and.returnValue(positivePromise)
                commit = jasmine.createSpy()

                state.contactId = 12
            })

            it('returns a promise', function () {
                var promise = actions.getContactData(apiServiceContext(dispatch, commit, state, getters))
                expect(typeof promise.then).toBe('function')
            })

            it('calls Step3APIService with the contactId', async function () {
                await actions.getContactData(apiServiceContext(dispatch, commit, state, getters))

                expect(step3StoreAPIServiceMock.getContactFromId.calls.count()).toEqual(1)
                expect(step3StoreAPIServiceMock.getContactFromId.calls.argsFor(0)).toEqual([12])
            })
        })
    })
})
