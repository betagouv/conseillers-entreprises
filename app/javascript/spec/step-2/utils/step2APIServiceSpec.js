import Step2APIService from '../../../packs/step-2/utils/step2APIService'

// for the async function to work
require('babel-core/register')

describe('Step2APIService', () => {
  describe('getDiagnosisContent', () => {
    var returnPromise

    describe('when the call is a success', function () {
      beforeEach(function () {
        const promise = Promise.resolve({data: {content: 'Content ?', id: 2}})
        spyOn(Step2APIService, 'send').and.returnValue(promise)

        returnPromise = Step2APIService.getDiagnosisContent(12)
      })

      it('calls send with the right arguments', function () {
        const config = {
          method: 'get',
          url: '/api/diagnoses/12'
        }
        expect(Step2APIService.send.calls.count()).toEqual(1)
        expect(Step2APIService.send.calls.argsFor(0)).toEqual([config])
      })

      it('returns a promise', function () {
        expect(typeof returnPromise.then).toBe('function')
      })

      it('does not return an error', async function () {
        let serviceResponse
        let serviceError

        await returnPromise
          .then((response) => {
            serviceResponse = response
          })
          .catch((error) => {
            serviceError = error
          })

        expect(serviceResponse).toEqual('Content ?')
        expect(serviceError).toBeUndefined()
      })
    })

    describe('when the call returns an error', function () {
      const error = new Error('error')
      beforeEach(function () {
        const promise = Promise.reject(error)
        spyOn(Step2APIService, 'send').and.returnValue(promise)

        returnPromise = Step2APIService.getDiagnosisContent(12)
      })

      it('calls send with the right arguments', function () {
        const config = {
          method: 'get',
          url: '/api/diagnoses/12'
        }
        expect(Step2APIService.send.calls.count()).toEqual(1)
        expect(Step2APIService.send.calls.argsFor(0)).toEqual([config])
      })

      it('returns a promise', function () {
        expect(typeof returnPromise.then).toBe('function')
      })

      it('returns an error', async function () {
        let serviceResponse
        let serviceError
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

  describe('updateDiagnosisContent', () => {
    var returnPromise

    describe('when the call is a success', function () {
      beforeEach(function () {
        var promise = Promise.resolve({data: ''})
        spyOn(Step2APIService, 'send').and.returnValue(promise)

        returnPromise = Step2APIService.updateDiagnosisContent(12, 'Awesome random stuff')
      })

      it('calls send with the right arguments', function () {
        var config = {
          method: 'patch',
          url: '/api/diagnoses/12',
          data: {
            diagnosis: {
              content: 'Awesome random stuff'
            }
          }
        }
        expect(Step2APIService.send.calls.count()).toEqual(1)
        expect(Step2APIService.send.calls.argsFor(0)).toEqual([config])
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

        expect(serviceResponse).toBeTruthy()
        expect(serviceError).toBeUndefined()
      })
    })

    describe('when the call returns an error', function () {
      const error = new Error('error')
      beforeEach(function () {
        var promise = Promise.reject(error)
        spyOn(Step2APIService, 'send').and.returnValue(promise)

        returnPromise = Step2APIService.updateDiagnosisContent(12, 'Awesome random stuff')
      })

      it('calls send with the right arguments', function () {
        var config = {
          method: 'patch',
          url: '/api/diagnoses/12',
          data: {
            diagnosis: {
              content: 'Awesome random stuff'
            }
          }
        }
        expect(Step2APIService.send.calls.count()).toEqual(1)
        expect(Step2APIService.send.calls.argsFor(0)).toEqual([config])
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

  describe('getDiagnosedNeeds', () => {
    var returnPromise

    describe('when the call is a success', function () {
      beforeEach(function () {
        const promise = Promise.resolve({
          data: [{
            id: 1,
            diagnosis_id: 23,
            question_id: 21,
            question_label: 'Question ?',
            content: 'Great content'
          }]
        })
        spyOn(Step2APIService, 'send').and.returnValue(promise)

        returnPromise = Step2APIService.getDiagnosedNeeds(12)
      })

      it('calls send with the right arguments', function () {
        const config = {
          method: 'get',
          url: '/api/diagnoses/12/diagnosed_needs'
        }
        expect(Step2APIService.send.calls.count()).toEqual(1)
        expect(Step2APIService.send.calls.argsFor(0)).toEqual([config])
      })

      it('returns a promise', function () {
        expect(typeof returnPromise.then).toBe('function')
      })

      it('does not return an error', async function () {
        let serviceResponse
        let serviceError

        await returnPromise
          .then((response) => {
            serviceResponse = response
          })
          .catch((error) => {
            serviceError = error
          })

        expect(serviceResponse).toEqual([{
          id: 1,
          diagnosis_id: 23,
          question_id: 21,
          question_label: 'Question ?',
          content: 'Great content'
        }])
        expect(serviceError).toBeUndefined()
      })
    })

    describe('when the call returns an error', function () {
      const error = new Error('error')
      beforeEach(function () {
        const promise = Promise.reject(error)
        spyOn(Step2APIService, 'send').and.returnValue(promise)

        returnPromise = Step2APIService.getDiagnosedNeeds(12)
      })

      it('calls send with the right arguments', function () {
        const config = {
          method: 'get',
          url: '/api/diagnoses/12/diagnosed_needs'
        }
        expect(Step2APIService.send.calls.count()).toEqual(1)
        expect(Step2APIService.send.calls.argsFor(0)).toEqual([config])
      })

      it('returns a promise', function () {
        expect(typeof returnPromise.then).toBe('function')
      })

      it('returns an error', async function () {
        let serviceResponse
        let serviceError
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

  describe('updateDiagnosedNeeds', () => {
    var returnPromise
    const diagnosedNeedBulkRequestBody = {
      create: [
        {
          question_id: 1,
          question_label: 'LABEL or label ?',
          content: 'This is content'
        }
      ],
      update: [
        {
          id: 12,
          content: 'This is updated content. Maybe.'
        }
      ],
      delete: [
        {
          id: 23
        }
      ]
    }

    describe('when the call is a success', function () {
      beforeEach(function () {
        var promise = Promise.resolve({})
        spyOn(Step2APIService, 'send').and.returnValue(promise)

        returnPromise = Step2APIService.updateDiagnosedNeeds(12, diagnosedNeedBulkRequestBody)
      })

      it('calls send with the right arguments', function () {
        var config = {
          method: 'post',
          url: '/api/diagnoses/12/diagnosed_needs/bulk',
          data: {
            bulk_params: diagnosedNeedBulkRequestBody
          }
        }
        expect(Step2APIService.send.calls.count()).toEqual(1)
        expect(Step2APIService.send.calls.argsFor(0)).toEqual([config])
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

        expect(serviceResponse).toBeTruthy()
        expect(serviceError).toBeUndefined()
      })
    })

    describe('when the call returns an error', function () {
      const error = new Error('error')
      beforeEach(function () {
        var promise = Promise.reject(error)
        spyOn(Step2APIService, 'send').and.returnValue(promise)

        returnPromise = Step2APIService.updateDiagnosedNeeds(12, diagnosedNeedBulkRequestBody)
      })

      it('calls send with the right arguments', function () {
        var config = {
          method: 'post',
          url: '/api/diagnoses/12/diagnosed_needs/bulk',
          data: {
            bulk_params: diagnosedNeedBulkRequestBody
          }
        }
        expect(Step2APIService.send.calls.count()).toEqual(1)
        expect(Step2APIService.send.calls.argsFor(0)).toEqual([config])
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
