import ErrorService from '../../packs/common/errorService'

//for the async function to work
require('babel-core/register')

describe('ErrorService', () => {

    describe('configureAPIErrorMessage', function () {

        it('prepends error message with an detailed message build from config', () => {
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
})