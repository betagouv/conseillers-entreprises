import Step2Store from '../../../packs/step-2/store/step2Store'

// for the async function to work
require('babel-core/register')

describe('step2Store', () => {
  describe('getters', () => {
    var getters = Step2Store.getters

    describe('getQuestionStateById', function () {
      it('gets the question matching the id', function () {
        const state = {
          questions: [
            { id: 'q12', content: 'CONTENT' },
            { id: 'd14', content: 'Pas CONTENT' }
          ]
        }
        const question = getters.getQuestionStateById(state, getters)('q12')
        expect(question.id).toEqual('q12')
        expect(question.content).toEqual('CONTENT')
      })
    })
  })

  describe('mutations', () => {
    var mutations = Step2Store.mutations

    describe('DIAGNOSIS_ID', function () {
      it('updates the diagnosisID', function () {
        const state = { diagnosisId: undefined }
        mutations.DIAGNOSIS_ID(state, '12')
        expect(state.diagnosisId).toEqual('12')
      })
    })

    describe('DIAGNOSIS_CONTENT', function () {
      it('updates the diagnosis content', function () {
        const state = { diagnosisContent: '' }
        mutations.DIAGNOSIS_CONTENT(state, 'Random Content')
        expect(state.diagnosisContent).toEqual('Random Content')
      })

      it('sets the diagnosis content at empty string if undefined is passed', function () {
        const state = { diagnosisContent: 'Random Content' }
        mutations.DIAGNOSIS_CONTENT(state, undefined)
        expect(state.diagnosisContent).toEqual('')
      })
    })

    describe('REQUEST_IN_PROGRESS', function () {
      it('updates the isDiagnosisRequestUnderWay', function () {
        const state = { isRequestInProgress: false }
        mutations.REQUEST_IN_PROGRESS(state, true)
        expect(state.isRequestInProgress).toBeTruthy()
      })
    })

    describe('QUESTION_ID', function () {
      it('creates the question in the questions array if it does not exist', function () {
        const state = { questions: [] }
        const expectedQuestions = [{ id: 'q1', questionId: 1 }]
        mutations.QUESTION_ID(state, { id: 'q1', questionId: 1 })
        expect(state.questions).toEqual(expectedQuestions)
      })
      it('does not destroy the question object in the questions array object if it already exists', function () {
        const state = {
          questions: [
            { id: 'q1', questionId: 1, randomProperty: false },
            { id: 'q2', questionId: 2, randomProperty: false }
          ]
        }
        const expectedQuestions = [
          { id: 'q1', questionId: 123, randomProperty: false },
          { id: 'q2', questionId: 2, randomProperty: false }
        ]
        mutations.QUESTION_ID(state, { id: 'q1', questionId: 123 })
        expect(state.questions).toEqual(expectedQuestions)
      })
    })

    describe('QUESTION_SELECTED', function () {
      it('creates the question in the questions array if it does not exist', function () {
        const state = { questions: [] }
        const expectedQuestions = [{ id: 'q1', isSelected: true }]
        mutations.QUESTION_SELECTED(state, { id: 'q1', isSelected: true })
        expect(state.questions).toEqual(expectedQuestions)
      })
      it('does not destroy the question object in the questions array object if it already exists', function () {
        const state = {
          questions: [
            { id: 'q1', isSelected: true, randomProperty: false },
            { id: 'q2', isSelected: false, randomProperty: false }
          ]
        }
        const expectedQuestions = [
          { id: 'q1', isSelected: false, randomProperty: false },
          { id: 'q2', isSelected: false, randomProperty: false }
        ]
        mutations.QUESTION_SELECTED(state, { id: 'q1', isSelected: false })
        expect(state.questions).toEqual(expectedQuestions)
      })
    })

    describe('QUESTION_CONTENT', function () {
      it('creates the question in the questions array if it does not exist', function () {
        const state = { questions: [] }
        const expectedQuestions = [{ id: 'q1', content: 'Potato everywhere' }]
        mutations.QUESTION_CONTENT(state, { id: 'q1', content: 'Potato everywhere' })
        expect(state.questions).toEqual(expectedQuestions)
      })
      it('does not destroy the question object in the questions array object if it already exists', function () {
        const state = {
          questions: [
            { id: 'q1', content: 'Content', randomProperty: true },
            { id: 'q2', content: 'Pas Content', randomProperty: false }
          ]
        }
        const expectedQuestions = [
          { id: 'q1', content: 'Potato everywhere', randomProperty: true },
          { id: 'q2', content: 'Pas Content', randomProperty: false }
        ]
        mutations.QUESTION_CONTENT(state, { id: 'q1', content: 'Potato everywhere' })
        expect(state.questions).toEqual(expectedQuestions)
      })
    })

    describe('QUESTION_LABEL', function () {
      it('creates the question in the questions array if it does not exist', function () {
        const state = { questions: [] }
        const expectedQuestions = [{ id: 'q1', questionLabel: 'OtherLabel' }]
        mutations.QUESTION_LABEL(state, { id: 'q1', questionLabel: 'OtherLabel' })
        expect(state.questions).toEqual(expectedQuestions)
      })
      it('does not destroy the question object in the questions array object if it already exists', function () {
        const state = {
          questions: [
            { id: 'q1', questionLabel: 'OtherLabel', randomProperty: true },
            { id: 'q2', questionLabel: 'Label...', randomProperty: false }
          ]
        }
        const expectedQuestions = [
          { id: 'q1', questionLabel: 'Duuuude', randomProperty: true },
          { id: 'q2', questionLabel: 'Label...', randomProperty: false }
        ]
        mutations.QUESTION_LABEL(state, { id: 'q1', questionLabel: 'Duuuude' })
        expect(state.questions).toEqual(expectedQuestions)
      })
    })

    describe('DIAGNOSED_NEED_ID', function () {
      it('creates the question in the questions array if it does not exist', function () {
        const state = { questions: [] }
        const expectedQuestions = [{ id: 'q1', diagnosedNeedId: 42 }]
        mutations.DIAGNOSED_NEED_ID(state, { id: 'q1', diagnosedNeedId: 42 })
        expect(state.questions).toEqual(expectedQuestions)
      })
      it('does not destroy the question object in the questions array object if it already exists', function () {
        const state = {
          questions: [
            { id: 'q1', diagnosedNeedId: 0, randomProperty: true },
            { id: 'q2', diagnosedNeedId: 53, randomProperty: false }
          ]
        }
        const expectedQuestions = [
          { id: 'q1', diagnosedNeedId: 42, randomProperty: true },
          { id: 'q2', diagnosedNeedId: 53, randomProperty: false }
        ]
        mutations.DIAGNOSED_NEED_ID(state, { id: 'q1', diagnosedNeedId: 42 })
        expect(state.questions).toEqual(expectedQuestions)
      })
    })
  })

  describe('actions', () => {
    var actions = Step2Store.actions

    var step2StoreAPIServiceMock = {
      updateDiagnosisContent: () => {
      },
      getDiagnosisContent: () => {
      },
      updateDiagnosedNeeds: () => {
      },
      getDiagnosedNeeds: () => {
      }
    }
    var apiServiceContext = function (commit, state) {
      return {
        commit: commit,
        state: state,
        step2APIServiceDependency: step2StoreAPIServiceMock
      }
    }

    describe('getDiagnosisContentValue', function () {
      var commit
      const state = {
        diagnosisContent: 'content 1',
        diagnosisId: 12,
        isDiagnosisRequestUnderWay: false
      }

      describe('when api call is a success', function () {
        const positivePromise = Promise.resolve('content 2!')

        beforeEach(function () {
          spyOn(step2StoreAPIServiceMock, 'getDiagnosisContent').and.returnValue(positivePromise)
          commit = jasmine.createSpy()
        })

        it('returns a promise', function () {
          var promise = actions.getDiagnosisContentValue(apiServiceContext(commit, state))
          expect(typeof promise.then).toBe('function')
        })

        it('calls contactAPIService with the diagnosisId and the content', async function () {
          await actions.getDiagnosisContentValue(apiServiceContext(commit, state))

          expect(step2StoreAPIServiceMock.getDiagnosisContent.calls.count()).toEqual(1)
          expect(step2StoreAPIServiceMock.getDiagnosisContent.calls.argsFor(0)).toEqual([12])
        })

        it('calls commit REQUEST_IN_PROGRESS with true at start of action', function () {
          actions.getDiagnosisContentValue(apiServiceContext(commit, state))

          expect(commit.calls.count()).toEqual(1)
          expect(commit.calls.argsFor(0)).toEqual([
            'REQUEST_IN_PROGRESS',
            true
          ])
        })

        it('calls commit DIAGNOSIS_CONTENT with the fetched content value', async function () {
          await actions.getDiagnosisContentValue(apiServiceContext(commit, state))

          expect(commit.calls.argsFor(1)).toEqual([
            'DIAGNOSIS_CONTENT',
            'content 2!'
          ])
        })

        it('calls commit REQUEST_IN_PROGRESS with false at end of action', async function () {
          await actions.getDiagnosisContentValue(apiServiceContext(commit, state))

          expect(commit.calls.count()).toEqual(3)
          expect(commit.calls.argsFor(2)).toEqual([
            'REQUEST_IN_PROGRESS',
            false
          ])
        })
      })

      describe('when api call throws an error', function () {
        const apiError = new Error('error :-(')
        const negativePromise = Promise.reject(apiError)

        beforeEach(function () {
          spyOn(step2StoreAPIServiceMock, 'getDiagnosisContent').and.returnValue(negativePromise)
          commit = jasmine.createSpy()
        })

        it('returns a promise', function () {
          var promise = actions.getDiagnosisContentValue(apiServiceContext(commit, state))
          expect(typeof promise.then).toBe('function')
        })

        it('calls contactAPIService with the diagnosisId and the content', async function () {
          await actions.getDiagnosisContentValue(apiServiceContext(commit, state)).catch(() => {
          })

          expect(step2StoreAPIServiceMock.getDiagnosisContent.calls.count()).toEqual(1)
          expect(step2StoreAPIServiceMock.getDiagnosisContent.calls.argsFor(0)).toEqual([12])
        })

        it('calls commit REQUEST_IN_PROGRESS with true at start of action', function () {
          actions.getDiagnosisContentValue(apiServiceContext(commit, state))

          expect(commit.calls.count()).toEqual(1)
          expect(commit.calls.argsFor(0)).toEqual([
            'REQUEST_IN_PROGRESS',
            true
          ])
        })

        it('calls commit REQUEST_IN_PROGRESS with false at end of action', async function () {
          await actions.getDiagnosisContentValue(apiServiceContext(commit, state)).catch(() => {
          })

          expect(commit.calls.count()).toEqual(2)
          expect(commit.calls.argsFor(1)).toEqual([
            'REQUEST_IN_PROGRESS',
            false
          ])
        })

        it('propagates the error', async function () {
          var catchedError
          await actions.getDiagnosisContentValue(apiServiceContext(commit, state))
            .catch((error) => {
              catchedError = error
            })
          expect(catchedError).toEqual(apiError)
        })
      })
    })

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

    describe('getDiagnosedNeeds', function () {
      var commit
      const state = {
        diagnosisId: 12
      }

      describe('when api call is a success', function () {
        const responseArray = [
          {
            id: 1,
            diagnosis_id: 23,
            question_id: 21,
            question_label: 'Question ?',
            content: 'Great content'
          },
          {
            id: 123,
            diagnosis_id: 23,
            question_id: null,
            question_label: 'Question ?',
            content: 'Another content'
          }
        ]
        const positivePromise = Promise.resolve(responseArray)

        beforeEach(function () {
          spyOn(step2StoreAPIServiceMock, 'getDiagnosedNeeds').and.returnValue(positivePromise)
          commit = jasmine.createSpy()
        })

        it('returns a promise', function () {
          var promise = actions.getDiagnosedNeeds(apiServiceContext(commit, state))
          expect(typeof promise.then).toBe('function')
        })

        it('calls contactAPIService with the diagnosisId and the content', async function () {
          await actions.getDiagnosedNeeds(apiServiceContext(commit, state))

          expect(step2StoreAPIServiceMock.getDiagnosedNeeds.calls.count()).toEqual(1)
          expect(step2StoreAPIServiceMock.getDiagnosedNeeds.calls.argsFor(0)).toEqual([12])
        })

        it('calls commit REQUEST_IN_PROGRESS with true at start of action', function () {
          actions.getDiagnosedNeeds(apiServiceContext(commit, state))

          expect(commit.calls.count()).toEqual(1)
          expect(commit.calls.argsFor(0)).toEqual([
            'REQUEST_IN_PROGRESS',
            true
          ])
        })

        it('calls commit with the fetched content values', async function () {
          await actions.getDiagnosedNeeds(apiServiceContext(commit, state))

          expect(commit.calls.argsFor(1)).toEqual(['QUESTION_SELECTED', { id: 'q21', isSelected: true }])
          expect(commit.calls.argsFor(2)).toEqual(['DIAGNOSED_NEED_ID', { id: 'q21', diagnosedNeedId: 1 }])
          expect(commit.calls.argsFor(3)).toEqual(['QUESTION_CONTENT', { id: 'q21', content: 'Great content' }])

          expect(commit.calls.argsFor(4)).toEqual(['QUESTION_SELECTED', { id: 'd123', isSelected: true }])
          expect(commit.calls.argsFor(5)).toEqual(['DIAGNOSED_NEED_ID', { id: 'd123', diagnosedNeedId: 123 }])
          expect(commit.calls.argsFor(6)).toEqual(['QUESTION_CONTENT', { id: 'd123', content: 'Another content' }])
        })

        it('calls commit REQUEST_IN_PROGRESS with false at end of action', async function () {
          await actions.getDiagnosedNeeds(apiServiceContext(commit, state))

          expect(commit.calls.count()).toEqual(8)
          expect(commit.calls.argsFor(7)).toEqual([
            'REQUEST_IN_PROGRESS',
            false
          ])
        })
      })

      describe('when api call throws an error', function () {
        const apiError = new Error('error :-(')
        const negativePromise = Promise.reject(apiError)

        beforeEach(function () {
          spyOn(step2StoreAPIServiceMock, 'getDiagnosedNeeds').and.returnValue(negativePromise)
          commit = jasmine.createSpy()
        })

        it('returns a promise', function () {
          var promise = actions.getDiagnosedNeeds(apiServiceContext(commit, state))
          expect(typeof promise.then).toBe('function')
        })

        it('calls contactAPIService with the diagnosisId and the content', async function () {
          await actions.getDiagnosedNeeds(apiServiceContext(commit, state)).catch(() => {
          })

          expect(step2StoreAPIServiceMock.getDiagnosedNeeds.calls.count()).toEqual(1)
          expect(step2StoreAPIServiceMock.getDiagnosedNeeds.calls.argsFor(0)).toEqual([12])
        })

        it('calls commit REQUEST_IN_PROGRESS with true at start of action', function () {
          actions.getDiagnosedNeeds(apiServiceContext(commit, state))

          expect(commit.calls.count()).toEqual(1)
          expect(commit.calls.argsFor(0)).toEqual([
            'REQUEST_IN_PROGRESS',
            true
          ])
        })

        it('calls commit REQUEST_IN_PROGRESS with false at end of action', async function () {
          await actions.getDiagnosedNeeds(apiServiceContext(commit, state)).catch(() => {
          })

          expect(commit.calls.count()).toEqual(2)
          expect(commit.calls.argsFor(1)).toEqual([
            'REQUEST_IN_PROGRESS',
            false
          ])
        })

        it('propagates the error', async function () {
          var catchedError
          await actions.getDiagnosedNeeds(apiServiceContext(commit, state))
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
      let state = {}

      beforeEach(function () {
        state = {
          diagnosisContent: 'content !',
          diagnosisId: 12,
          isDiagnosisRequestUnderWay: false,
          questions: questions
        }
      })

      describe('when there is no change to send', function () {
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
