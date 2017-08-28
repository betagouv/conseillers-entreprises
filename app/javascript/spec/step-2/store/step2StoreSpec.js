import axios from 'axios'
import Step2Store from '../../../packs/step-2/store/step2Store'

//for the async function to work
require('babel-core/register')

describe('step2Store', () => {

    describe('getters', () => {

        var getters = Step2Store.getters

        describe('getQuestionStateById', function () {

            it('gets the question matching the id', function () {
                const state = {
                    questions: [
                        {questionId: 12, content: 'CONTENT'},
                        {questionId: 14, content: 'Pas CONTENT'}
                    ]
                }
                const question = getters.getQuestionStateById(state, getters)(12)
                expect(question.questionId).toEqual(12)
                expect(question.content).toEqual('CONTENT')
            })
        })
    })

    describe('mutations', () => {

        var mutations = Step2Store.mutations

        describe('DIAGNOSIS_ID', function () {

            it('updates the diagnosisID', function () {
                const state = {diagnosisId: undefined}
                mutations.DIAGNOSIS_ID(state, '12')
                expect(state.diagnosisId).toEqual('12')
            })
        })

        describe('DIAGNOSIS_CONTENT', function () {

            it('updates the diagnosis content', function () {
                const state = {diagnosisContent: ''}
                mutations.DIAGNOSIS_CONTENT(state, 'Random Content')
                expect(state.diagnosisContent).toEqual('Random Content')
            })

            it('sets the diagnosis content at empty string if undefined is passed', function () {
                const state = {diagnosisContent: 'Random Content'}
                mutations.DIAGNOSIS_CONTENT(state, undefined)
                expect(state.diagnosisContent).toEqual('')
            })
        })

        describe('REQUEST_IN_PROGRESS', function () {

            it('updates the isDiagnosisRequestUnderWay', function () {
                const state = {isRequestInProgress: false}
                mutations.REQUEST_IN_PROGRESS(state, true)
                expect(state.isRequestInProgress).toBeTruthy()
            })
        })

        describe('QUESTION_SELECTED', function () {

            it('create the question in the questions array if it does not exist', function () {
                const state = {questions: []}
                const expectedQuestions = [{questionId: '1', isSelected: true}]
                mutations.QUESTION_SELECTED(state, {questionId: '1', isSelected: true})
                expect(state.questions).toEqual(expectedQuestions)
            })
            it('does not destroy the question object in the questions array object if it already exists', function () {
                const state = {
                    questions: [
                        {questionId: '1', isSelected: true, randomProperty: false},
                        {questionId: '2', isSelected: false, randomProperty: false}
                    ]
                }
                const expectedQuestions = [
                    {questionId: '1', isSelected: false, randomProperty: false},
                    {questionId: '2', isSelected: false, randomProperty: false}
                ]
                mutations.QUESTION_SELECTED(state, {questionId: '1', isSelected: false})
                expect(state.questions).toEqual(expectedQuestions)
            })
        })

        describe('QUESTION_CONTENT', function () {

            it('creates the question in the questions array if it does not exist', function () {
                const state = {questions: []}
                const expectedQuestions = [{questionId: '1', content: 'Potato everywhere'}]
                mutations.QUESTION_CONTENT(state, {questionId: '1', content: 'Potato everywhere'})
                expect(state.questions).toEqual(expectedQuestions)
            })
            it('does not destroy the question object in the questions array object if it already exists', function () {
                const state = {
                    questions: [
                        {questionId: '1', content: 'Content', randomProperty: true},
                        {questionId: '2', content: 'Pas Content', randomProperty: false}
                    ]
                }
                const expectedQuestions = [
                    {questionId: '1', content: 'Potato everywhere', randomProperty: true},
                    {questionId: '2', content: 'Pas Content', randomProperty: false}
                ]
                mutations.QUESTION_CONTENT(state, {questionId: '1', content: 'Potato everywhere'})
                expect(state.questions).toEqual(expectedQuestions)
            })
        })

        describe('QUESTION_LABEL', function () {

            it('creates the question in the questions array if it does not exist', function () {
                const state = {questions: []}
                const expectedQuestions = [{questionId: '1', questionLabel: 'OtherLabel'}]
                mutations.QUESTION_LABEL(state, {questionId: '1', questionLabel: 'OtherLabel'})
                expect(state.questions).toEqual(expectedQuestions)
            })
            it('does not destroy the question object in the questions array object if it already exists', function () {
                const state = {
                    questions: [
                        {questionId: '1', questionLabel: 'OtherLabel', randomProperty: true},
                        {questionId: '1', questionLabel: 'Label...', randomProperty: false}
                    ]
                }
                const expectedQuestions = [
                    {questionId: '1', questionLabel: 'Duuuude', randomProperty: true},
                    {questionId: '1', questionLabel: 'Label...', randomProperty: false}
                ]
                mutations.QUESTION_LABEL(state, {questionId: '1', questionLabel: 'Duuuude'})
                expect(state.questions).toEqual(expectedQuestions)
            })
        })

        describe('DIAGNOSIS_NEED_ID', function () {

            it('creates the question in the questions array if it does not exist', function () {
                const state = {questions: []}
                const expectedQuestions = [{questionId: 1, diagnosedNeedId: 42}]
                mutations.DIAGNOSIS_NEED_ID(state, {questionId: 1, diagnosedNeedId: 42})
                expect(state.questions).toEqual(expectedQuestions)
            })
            it('does not destroy the question object in the questions array object if it already exists', function () {
                const state = {
                    questions: [
                        {questionId: 1, diagnosedNeedId: 0, randomProperty: true},
                        {questionId: 2, diagnosedNeedId: 53, randomProperty: false}
                    ]
                }
                const expectedQuestions = [
                    {questionId: 1, diagnosedNeedId: 42, randomProperty: true},
                    {questionId: 2, diagnosedNeedId: 53, randomProperty: false}
                ]
                mutations.DIAGNOSIS_NEED_ID(state, {questionId: 1, diagnosedNeedId: 42})
                expect(state.questions).toEqual(expectedQuestions)
            })
        })
    })

    describe('actions', () => {

        var actions = Step2Store.actions

        var step2StoreAPIServiceMock = {
            updateDiagnosisContent: () => {
            },
            createDiagnosedNeeds: () => {
            },
            updateDiagnosedNeeds: () => {
            }
        }
        var apiServiceContext = function (commit, state) {
            return {
                commit: commit,
                state: state,
                step2APIServiceDependency: step2StoreAPIServiceMock
            }
        }

        describe('updateDiagnosisContent', function () {

            var commit
            const state = {
                diagnosisContent: 'content !',
                diagnosisId: 12,
                isDiagnosisRequestUnderWay: false
            }

            describe('when api call is a success', function () {

                const positivePromise = Promise.resolve(true)

                beforeEach(function () {
                    spyOn(step2StoreAPIServiceMock, 'updateDiagnosisContent').and.returnValue(positivePromise)
                    commit = jasmine.createSpy()
                })

                it('returns a promise', function () {
                    var promise = actions.sendDiagnosisContentUpdate(apiServiceContext(commit, state))
                    expect(typeof promise.then).toBe('function')
                })

                it('calls contactAPIService with the diagnosisId and the content', async function () {
                    await actions.sendDiagnosisContentUpdate(apiServiceContext(commit, state))

                    expect(step2StoreAPIServiceMock.updateDiagnosisContent.calls.count()).toEqual(1)
                    expect(step2StoreAPIServiceMock.updateDiagnosisContent.calls.argsFor(0)).toEqual([12, 'content !'])
                })

                it('calls commit REQUEST_IN_PROGRESS with true at start of action', function () {
                    actions.sendDiagnosisContentUpdate(apiServiceContext(commit, state))

                    expect(commit.calls.count()).toEqual(1)
                    expect(commit.calls.argsFor(0)).toEqual([
                        'REQUEST_IN_PROGRESS',
                        true
                    ])
                })

                it('calls commit REQUEST_IN_PROGRESS with false at end of action', async function () {
                    await actions.sendDiagnosisContentUpdate(apiServiceContext(commit, state))

                    expect(commit.calls.count()).toEqual(2)
                    expect(commit.calls.argsFor(1)).toEqual([
                        'REQUEST_IN_PROGRESS',
                        false
                    ])
                })
            })

            describe('when api call throws an error', function () {

                const apiError = new Error('error :-(')
                const negativePromise = Promise.reject(apiError)

                beforeEach(function () {
                    spyOn(step2StoreAPIServiceMock, 'updateDiagnosisContent').and.returnValue(negativePromise)
                    commit = jasmine.createSpy()
                })

                it('returns a promise', function () {
                    var promise = actions.sendDiagnosisContentUpdate(apiServiceContext(commit, state))
                    expect(typeof promise.then).toBe('function')
                })

                it('calls contactAPIService with the diagnosisId and the content', async function () {
                    await actions.sendDiagnosisContentUpdate(apiServiceContext(commit, state)).catch(() => {
                    })

                    expect(step2StoreAPIServiceMock.updateDiagnosisContent.calls.count()).toEqual(1)
                    expect(step2StoreAPIServiceMock.updateDiagnosisContent.calls.argsFor(0)).toEqual([12, 'content !'])
                })

                it('calls commit REQUEST_IN_PROGRESS with true at start of action', function () {
                    actions.sendDiagnosisContentUpdate(apiServiceContext(commit, state))

                    expect(commit.calls.count()).toEqual(1)
                    expect(commit.calls.argsFor(0)).toEqual([
                        'REQUEST_IN_PROGRESS',
                        true
                    ])
                })

                it('calls commit REQUEST_IN_PROGRESS with false at end of action', async function () {
                    await actions.sendDiagnosisContentUpdate(apiServiceContext(commit, state)).catch(() => {
                    })

                    expect(commit.calls.count()).toEqual(2)
                    expect(commit.calls.argsFor(1)).toEqual([
                        'REQUEST_IN_PROGRESS',
                        false
                    ])
                })

                it('propagates the error', async function () {
                    var catchedError
                    await actions.sendDiagnosisContentUpdate(apiServiceContext(commit, state))
                        .catch((error) => {
                            catchedError = error
                        })
                    expect(catchedError).toEqual(apiError)
                })
            })
        })

        describe('createSelectedQuestions', function () {

            var commit
            const questions = [
                {
                    isSelected: true,
                    questionId: '23',
                    questionLabel: 'Some Question',
                    content: 'Awesome random stuff'
                },
                {
                    isSelected: false,
                    questionId: '43',
                    questionLabel: 'QUESTION',
                    content: 'I need anwsers !'
                }
            ]
            const selectedQuestions = questions.filter((question) => {
                return question.isSelected
            })
            let state = {}

            beforeEach(function() {
                state = {
                    diagnosisContent: 'content !',
                    diagnosisId: 12,
                    isDiagnosisRequestUnderWay: false,
                    questions: questions
                }
            })

            describe('when there is no questions to send', function () {

                const positivePromise = Promise.resolve(true)

                beforeEach(function () {
                    spyOn(step2StoreAPIServiceMock, 'createDiagnosedNeeds').and.returnValue(positivePromise)
                    commit = jasmine.createSpy()
                    state.questions = []
                })

                it('returns a promise', function () {
                    var promise = actions.createSelectedQuestions(apiServiceContext(commit, state))
                    expect(typeof promise.then).toBe('function')
                })

                it('should not call contactAPIService', async function () {
                    await actions.createSelectedQuestions(apiServiceContext(commit, state))

                    expect(step2StoreAPIServiceMock.createDiagnosedNeeds.calls.count()).toEqual(0)
                })

                it('does not call commit REQUEST_IN_PROGRESS', async function () {
                    await actions.createSelectedQuestions(apiServiceContext(commit, state))

                    expect(commit.calls.count()).toEqual(0)
                })
            })

            describe('when api call is a success', function () {

                const positivePromise = Promise.resolve(true)

                beforeEach(function () {
                    spyOn(step2StoreAPIServiceMock, 'createDiagnosedNeeds').and.returnValue(positivePromise)
                    commit = jasmine.createSpy()
                })

                it('returns a promise', function () {
                    var promise = actions.createSelectedQuestions(apiServiceContext(commit, state))
                    expect(typeof promise.then).toBe('function')
                })

                it('calls contactAPIService with the diagnosisId and the diagnosedNeeds', async function () {
                    await actions.createSelectedQuestions(apiServiceContext(commit, state))

                    expect(step2StoreAPIServiceMock.createDiagnosedNeeds.calls.count()).toEqual(1)
                    expect(step2StoreAPIServiceMock.createDiagnosedNeeds.calls.argsFor(0)).toEqual([12, selectedQuestions])
                })

                it('calls commit REQUEST_IN_PROGRESS with true at start of action', function () {
                    actions.createSelectedQuestions(apiServiceContext(commit, state))

                    expect(commit.calls.count()).toEqual(1)
                    expect(commit.calls.argsFor(0)).toEqual([
                        'REQUEST_IN_PROGRESS',
                        true
                    ])
                })

                it('calls commit REQUEST_IN_PROGRESS with false at end of action', async function () {
                    await actions.createSelectedQuestions(apiServiceContext(commit, state))

                    expect(commit.calls.count()).toEqual(2)
                    expect(commit.calls.argsFor(1)).toEqual([
                        'REQUEST_IN_PROGRESS',
                        false
                    ])
                })
            })

            describe('when api call throws an error', function () {

                const apiError = new Error('error :-(')
                const negativePromise = Promise.reject(apiError)

                beforeEach(function () {
                    spyOn(step2StoreAPIServiceMock, 'createDiagnosedNeeds').and.returnValue(negativePromise)
                    commit = jasmine.createSpy()
                })

                it('returns a promise', function () {
                    var promise = actions.createSelectedQuestions(apiServiceContext(commit, state))
                    expect(typeof promise.then).toBe('function')
                })

                it('calls contactAPIService with the diagnosisId and the content', async function () {
                    await actions.createSelectedQuestions(apiServiceContext(commit, state)).catch(() => {
                    })

                    expect(step2StoreAPIServiceMock.createDiagnosedNeeds.calls.count()).toEqual(1)
                    expect(step2StoreAPIServiceMock.createDiagnosedNeeds.calls.argsFor(0)).toEqual([12, selectedQuestions])
                })

                it('calls commit REQUEST_IN_PROGRESS with true at start of action', function () {
                    actions.createSelectedQuestions(apiServiceContext(commit, state))

                    expect(commit.calls.count()).toEqual(1)
                    expect(commit.calls.argsFor(0)).toEqual([
                        'REQUEST_IN_PROGRESS',
                        true
                    ])
                })

                it('calls commit REQUEST_IN_PROGRESS with false at end of action', async function () {
                    await actions.createSelectedQuestions(apiServiceContext(commit, state)).catch(() => {
                    })

                    expect(commit.calls.count()).toEqual(2)
                    expect(commit.calls.argsFor(1)).toEqual([
                        'REQUEST_IN_PROGRESS',
                        false
                    ])
                })

                it('propagates the error', async function () {
                    var catchedError
                    await actions.createSelectedQuestions(apiServiceContext(commit, state))
                        .catch((error) => {
                            catchedError = error
                        })
                    expect(catchedError).toEqual(apiError)
                })
            })
        })

        describe('updateDiagnosedNeeds', function () {

            var commit
            const questions = [
                {
                    isSelected: true,
                    questionId: 23,
                    questionLabel: 'Some Question',
                    diagnosedNeedId: undefined,
                    content: 'Awesome random stuff'
                },
                {
                    isSelected: false,
                    questionId: 43,
                    questionLabel: 'QUESTION',
                    diagnosedNeedId: 12,
                    content: 'I need anwsers !'
                }
            ]
            const expectedDiagnosedNeedBulkRequestBody = {
                create: [
                    {
                        question_id: 23,
                        question_label: 'Some Question',
                        content: 'Awesome random stuff'
                    }
                ],
                update: [],
                delete: [
                    {
                        id: 12
                    }
                ]
            }

            const selectedQuestions = questions.filter((question) => {
                return question.isSelected
            })
            let state = {}

            beforeEach(function() {
                state = {
                    diagnosisContent: 'content !',
                    diagnosisId: 12,
                    isDiagnosisRequestUnderWay: false,
                    questions: questions
                }
            })

            describe('when there is no changes to send', function () {

                const positivePromise = Promise.resolve(true)

                beforeEach(function () {
                    spyOn(step2StoreAPIServiceMock, 'updateDiagnosedNeeds').and.returnValue(positivePromise)
                    commit = jasmine.createSpy()
                    state.questions = []
                })

                it('returns a promise', function () {
                    var promise = actions.sendDiagnosedNeedsBulkUpdate(apiServiceContext(commit, state))
                    expect(typeof promise.then).toBe('function')
                })

                it('should not call contactAPIService', async function () {
                    await actions.sendDiagnosedNeedsBulkUpdate(apiServiceContext(commit, state))

                    expect(step2StoreAPIServiceMock.updateDiagnosedNeeds.calls.count()).toEqual(0)
                })

                it('does not call commit REQUEST_IN_PROGRESS', async function () {
                    await actions.sendDiagnosedNeedsBulkUpdate(apiServiceContext(commit, state))

                    expect(commit.calls.count()).toEqual(0)
                })
            })

            describe('when api call is a success', function () {

                const positivePromise = Promise.resolve(true)

                beforeEach(function () {
                    spyOn(step2StoreAPIServiceMock, 'updateDiagnosedNeeds').and.returnValue(positivePromise)
                    commit = jasmine.createSpy()
                })

                it('returns a promise', function () {
                    var promise = actions.sendDiagnosedNeedsBulkUpdate(apiServiceContext(commit, state))
                    expect(typeof promise.then).toBe('function')
                })

                it('calls contactAPIService with the diagnosisId and the diagnosedNeeds', async function () {
                    await actions.sendDiagnosedNeedsBulkUpdate(apiServiceContext(commit, state))

                    expect(step2StoreAPIServiceMock.updateDiagnosedNeeds.calls.count()).toEqual(1)
                    expect(step2StoreAPIServiceMock.updateDiagnosedNeeds.calls.argsFor(0)).toEqual([12, expectedDiagnosedNeedBulkRequestBody])
                })

                it('calls commit REQUEST_IN_PROGRESS with true at start of action', function () {
                    actions.sendDiagnosedNeedsBulkUpdate(apiServiceContext(commit, state))

                    expect(commit.calls.count()).toEqual(1)
                    expect(commit.calls.argsFor(0)).toEqual([
                        'REQUEST_IN_PROGRESS',
                        true
                    ])
                })

                it('calls commit REQUEST_IN_PROGRESS with false at end of action', async function () {
                    await actions.sendDiagnosedNeedsBulkUpdate(apiServiceContext(commit, state))

                    expect(commit.calls.count()).toEqual(2)
                    expect(commit.calls.argsFor(1)).toEqual([
                        'REQUEST_IN_PROGRESS',
                        false
                    ])
                })
            })

            describe('when api call throws an error', function () {

                const apiError = new Error('error :-(')
                const negativePromise = Promise.reject(apiError)

                beforeEach(function () {
                    spyOn(step2StoreAPIServiceMock, 'updateDiagnosedNeeds').and.returnValue(negativePromise)
                    commit = jasmine.createSpy()
                })

                it('returns a promise', function () {
                    var promise = actions.sendDiagnosedNeedsBulkUpdate(apiServiceContext(commit, state))
                    expect(typeof promise.then).toBe('function')
                })

                it('calls contactAPIService with the diagnosisId and the content', async function () {
                    await actions.sendDiagnosedNeedsBulkUpdate(apiServiceContext(commit, state)).catch(() => {
                    })

                    expect(step2StoreAPIServiceMock.updateDiagnosedNeeds.calls.count()).toEqual(1)
                    expect(step2StoreAPIServiceMock.updateDiagnosedNeeds.calls.argsFor(0)).toEqual([12, expectedDiagnosedNeedBulkRequestBody])
                })

                it('calls commit REQUEST_IN_PROGRESS with true at start of action', function () {
                    actions.sendDiagnosedNeedsBulkUpdate(apiServiceContext(commit, state))

                    expect(commit.calls.count()).toEqual(1)
                    expect(commit.calls.argsFor(0)).toEqual([
                        'REQUEST_IN_PROGRESS',
                        true
                    ])
                })

                it('calls commit REQUEST_IN_PROGRESS with false at end of action', async function () {
                    await actions.sendDiagnosedNeedsBulkUpdate(apiServiceContext(commit, state)).catch(() => {
                    })

                    expect(commit.calls.count()).toEqual(2)
                    expect(commit.calls.argsFor(1)).toEqual([
                        'REQUEST_IN_PROGRESS',
                        false
                    ])
                })

                it('propagates the error', async function () {
                    var catchedError
                    await actions.sendDiagnosedNeedsBulkUpdate(apiServiceContext(commit, state))
                        .catch((error) => {
                            catchedError = error
                        })
                    expect(catchedError).toEqual(apiError)
                })
            })
        })
    })
})
