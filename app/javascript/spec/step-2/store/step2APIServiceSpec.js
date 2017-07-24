import Step2APIService from '../../../packs/step-2/store/step2APIService'

//for the async function to work
require('babel-core/register')
require('babel-polyfill')

describe('Step2APIService', () => {

    describe('udpateDiagnosisContent', () => {

        var returnPromise

        describe('when the call is a success', function () {

            beforeEach(function () {
                var promise = Promise.resolve({data: ''})
                spyOn(Step2APIService, 'send').and.returnValue(promise)

                returnPromise = Step2APIService.udpateDiagnosisContent(12, 'Awesome random stuff')
            })

            it('calls send with the right arguments', function () {
                var config = {
                    method: 'patch',
                    url: `/api/diagnoses/12`,
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

            let error = new Error('error')
            beforeEach(function () {
                var promise = Promise.reject(error)
                spyOn(Step2APIService, 'send').and.returnValue(promise)

                returnPromise = Step2APIService.udpateDiagnosisContent(12, 'Awesome random stuff')
            })

            it('calls send with the right arguments', function () {
                var config = {
                    method: 'patch',
                    url: `/api/diagnoses/12`,
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

    describe('createDiagnosedNeeds', () => {

        var returnPromise
        const diagnosedNeeds = [
            {
                questionId: '23',
                questionLabel: 'Some Question',
                content: 'Awesome random stuff'
            }
        ]

        describe('when the call is a success', function () {

            beforeEach(function () {
                var promise = Promise.resolve({})
                spyOn(Step2APIService, 'send').and.returnValue(promise)

                returnPromise = Step2APIService.createDiagnosedNeeds(12, diagnosedNeeds)
            })

            it('calls send with the right arguments', function () {
                var config = {
                    method: 'post',
                    url: `/api/diagnoses/12/diagnosed_needs`,
                    data: {
                        diagnosed_needs: [
                            {
                                question_id: '23',
                                question_label: 'Some Question',
                                content: 'Awesome random stuff'
                            }
                        ]
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

            let error = new Error('error')
            beforeEach(function () {
                var promise = Promise.reject(error)
                spyOn(Step2APIService, 'send').and.returnValue(promise)

                returnPromise = Step2APIService.createDiagnosedNeeds(12, diagnosedNeeds)
            })

            it('calls send with the right arguments', function () {
                var config = {
                    method: 'post',
                    url: `/api/diagnoses/12/diagnosed_needs`,
                    data: {
                        diagnosed_needs: [
                            {
                                question_id: '23',
                                question_label: 'Some Question',
                                content: 'Awesome random stuff'
                            }
                        ]
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