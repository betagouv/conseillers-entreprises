import ErrorService from '../../packs/common/errorService'

//for the async function to work
require('babel-core/register')

describe('ErrorService', () => {

    describe('configureAPIErrorMessage', function () {

        it('prepends error message with a detailed message build from config', () => {
            let error = new Error('Nice error message')
            const config = {
                method: 'get',
                url: `/api/diagnoses/12/diagnosed_needs`
            }

            const newError = ErrorService.configureAPIErrorMessage(error, config)
            const message = `API get call request to: /api/diagnoses/12/diagnosed_needs | Nice error message`
            expect(newError.message).toEqual(message)
        })
    })

    describe('sendErrorReport', () => {

        let returnPromise
        const errorReport = {
            'message': 'Script error.',
            'mode': 'onerror',
            'stack': [{'url': '', 'line': 0, 'column': 0, 'func': '?', 'context': null}]
        }

        describe('with a success', function () {

            beforeEach(function () {
                const promise = Promise.resolve(true)
                spyOn(ErrorService, 'send').and.returnValue(promise)

                ErrorService.sendErrorReport(errorReport)
            })

            it('calls send with the right arguments', function () {
                const config = {
                    method: 'post',
                    url: '/api/errors',
                    data: {
                        error_report: errorReport
                    }
                }
                expect(ErrorService.send.calls.count()).toEqual(1)
                expect(ErrorService.send.calls.argsFor(0)).toEqual([config])
            })
        })
    })
})