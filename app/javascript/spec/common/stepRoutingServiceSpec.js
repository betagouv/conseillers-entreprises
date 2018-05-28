import StepRoutingService from '../../packs/common/stepRoutingService'

// for the async function to work
require('babel-core/register')

// Babel is required here once, but is used for all following tests. (This test is the first to be run.)
// If removed, it fails. If added in another test file, it fails.
// TODO: Move in another file? Remove from here?
require('babel-polyfill')

describe('StepRoutingService', () => {
  describe('go_to_step', () => {
    let returnPromise
    let stepRoutingService

    beforeEach(function () {
      stepRoutingService = new StepRoutingService(2)
    })

    describe('with a success', function () {
      beforeEach(function () {
        const promise = Promise.resolve(true)
        spyOn(StepRoutingService, 'send').and.returnValue(promise)
        spyOn(StepRoutingService, 'goTo')

        returnPromise = stepRoutingService.goToStep(3)
      })

      it('returns a promise', function () {
        expect(typeof returnPromise.then).toBe('function')
      })

      it('calls send with the right arguments', async function () {
        await returnPromise.catch(function () {
        })

        const config = {
          method: 'patch',
          url: '/api/diagnoses/2',
          data: {
            diagnosis: {
              step: 3
            }
          }
        }
        expect(StepRoutingService.send.calls.count()).toEqual(1)
        expect(StepRoutingService.send.calls.argsFor(0)).toEqual([config])
      })

      it('calls goTo with the right arguments', async function () {
        await returnPromise.catch(function () {
        })

        const expectedUrl = '/diagnoses/2/step-3'
        expect(StepRoutingService.goTo.calls.count()).toEqual(1)
        expect(StepRoutingService.goTo.calls.argsFor(0)).toEqual([expectedUrl])
      })
    })

    describe('with an error', function () {
      const error = new Error('error')
      beforeEach(function () {
        const promise = Promise.reject(error)
        spyOn(StepRoutingService, 'send').and.returnValue(promise)
        spyOn(StepRoutingService, 'goTo')

        returnPromise = stepRoutingService.goToStep(3)
      })

      it('returns a promise', function () {
        expect(typeof returnPromise.then).toBe('function')
      })

      it('calls send with the right arguments', async function () {
        await returnPromise.catch(function () {
        })

        const config = {
          method: 'patch',
          url: '/api/diagnoses/2',
          data: {
            diagnosis: {
              step: 3
            }
          }
        }
        expect(StepRoutingService.send.calls.count()).toEqual(1)
        expect(StepRoutingService.send.calls.argsFor(0)).toEqual([config])
      })

      it('does not call go_to', async function () {
        await returnPromise.catch(function () {
        })

        expect(StepRoutingService.goTo.calls.count()).toEqual(0)
      })
    })
  })
})
