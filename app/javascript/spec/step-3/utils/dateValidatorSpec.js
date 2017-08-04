import DateValidator from '../../../packs/step-3/utils/dateValidator'

//for the async function to work
require('babel-core/register')
require('babel-polyfill')

describe('DateValidator', () => {

    describe('isEmpty', () => {

        it('return true when string is empty', function () {
            const stringDate = ''

            const isEmpty = new DateValidator(stringDate).isEmpty
            expect(isEmpty).toBeTruthy()
        })

        it('return true when string is not empty', function () {
            const stringDate = 'not empty'

            const isEmpty = new DateValidator(stringDate).isEmpty
            expect(isEmpty).toBeFalsy()
        })
    })

    describe('isValid', () => {

        it('return true when date in the format DD/MM/YYYY', function () {
            const stringDate = '22/12/1992'

            const isValid = new DateValidator(stringDate).isValid
            expect(isValid).toBeTruthy()
        })


        it('return true when date in the format YYYY-MM-DD', function () {
            const stringDate = '2020-03-23'

            const isValid = new DateValidator(stringDate).isValid
            expect(isValid).toBeTruthy()
        })

        it('return false when date is not in the supported format', function () {
            const stringDate = '2-12-1992'

            const isValid = new DateValidator(stringDate).isValid
            expect(isValid).toBeFalsy()
        })

        it('return false when date is in a supported format but values are wrong', function () {
            const stringDate = '99/12/1992'

            const isValid = new DateValidator(stringDate).isValid
            expect(isValid).toBeFalsy()
        })
    })

    describe('isoString', () => {

        it('return an empty string when date is not valid', function () {
            const stringDate = '99/12/1992'

            const isoString = new DateValidator(stringDate).toIsoString
            expect(isoString).toEqual('')
        })

        it('return an iso formated string when date is valid', function () {
            const stringDate = '22/12/1992'
            const expectedDate = '1992-12-22'

            const isoString = new DateValidator(stringDate).toIsoString
            expect(isoString).toEqual(expectedDate)
        })
    })
})
