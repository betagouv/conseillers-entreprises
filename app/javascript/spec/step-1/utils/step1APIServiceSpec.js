import Step1APIService from '../../../packs/step-1/utils/step1APIService'

// for the async function to work
require('babel-core/register')

describe('Step1APIService', () => {
  describe('createDiagnosis', () => {
    var returnPromise

    describe('when the call is a success', function () {
      beforeEach(function () {
        var promise = Promise.resolve({data: {id: 23}})
        spyOn(Step1APIService, 'send').and.returnValue(promise)

        returnPromise = Step1APIService.createDiagnosis('12345678901234')
      })

      it('calls send with the right arguments', function () {
        const config = {
          method: 'post',
          url: '/api/diagnoses',
          data: {
            siret: '12345678901234'
          }
        }
        expect(Step1APIService.send.calls.count()).toEqual(1)
        expect(Step1APIService.send.calls.argsFor(0)).toEqual([config])
      })

      it('returns a promise', function () {
        expect(typeof returnPromise.then).toBe('function')
      })

      it('does not return an error', async function () {
        var serviceResponse
        var serviceError

        await returnPromise
          .then((response) => {
            serviceResponse = response
          })
          .catch((error) => {
            serviceError = error
          })

        expect(serviceResponse).toEqual(23)
        expect(serviceError).toBeUndefined()
      })
    })

    describe('when the call returns an error', function () {
      const error = new Error('error')
      beforeEach(function () {
        var promise = Promise.reject(error)
        spyOn(Step1APIService, 'send').and.returnValue(promise)

        returnPromise = Step1APIService.createDiagnosis('12345678901234')
      })

      it('calls send with the right arguments', function () {
        const config = {
          method: 'post',
          url: '/api/diagnoses',
          data: {
            siret: '12345678901234'
          }
        }
        expect(Step1APIService.send.calls.count()).toEqual(1)
        expect(Step1APIService.send.calls.argsFor(0)).toEqual([config])
      })

      it('returns a promise', function () {
        expect(typeof returnPromise.then).toBe('function')
      })

      it('returns an error', async function () {
        var serviceResponse
        var serviceError
        await returnPromise
          .then((response) => {
            serviceResponse = response
          })
          .catch((error) => {
            serviceError = error
          })

        expect(serviceResponse).toBeUndefined()
        expect(serviceError).toEqual(error)
      })
    })
  })
})
