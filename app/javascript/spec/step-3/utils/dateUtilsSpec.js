import DateUtils from '../../../packs/step-3/utils/dateUtils'

//for the async function to work
require('babel-core/register')
require('babel-polyfill')

describe('DateUtils', () => {

    const testDate = new Date(2017, 6, 26)
    let dateUtils

    beforeEach(() => {
        dateUtils = new DateUtils(testDate)
    })

    describe('dateString', () => {

        it('creates the month object', function () {
            const expectedDate = '2017-07-26'
            expect(dateUtils.dateString).toEqual(expectedDate)
        })
    })

    describe('daysOfMonth', () => {

        it('creates the month object', function () {
            const expectedDaysOfMonth = [
                [
                    {day: 26, selected: false, inCurrentMonth: false},
                    {day: 27, selected: false, inCurrentMonth: false},
                    {day: 28, selected: false, inCurrentMonth: false},
                    {day: 29, selected: false, inCurrentMonth: false},
                    {day: 30, selected: false, inCurrentMonth: false},
                    {day: 1, selected: false, inCurrentMonth: true},
                    {day: 2, selected: false, inCurrentMonth: true}
                ],
                [
                    {day: 3, selected: false, inCurrentMonth: true},
                    {day: 4, selected: false, inCurrentMonth: true},
                    {day: 5, selected: false, inCurrentMonth: true},
                    {day: 6, selected: false, inCurrentMonth: true},
                    {day: 7, selected: false, inCurrentMonth: true},
                    {day: 8, selected: false, inCurrentMonth: true},
                    {day: 9, selected: false, inCurrentMonth: true}
                ],
                [
                    {day: 10, selected: false, inCurrentMonth: true},
                    {day: 11, selected: false, inCurrentMonth: true},
                    {day: 12, selected: false, inCurrentMonth: true},
                    {day: 13, selected: false, inCurrentMonth: true},
                    {day: 14, selected: false, inCurrentMonth: true},
                    {day: 15, selected: false, inCurrentMonth: true},
                    {day: 16, selected: false, inCurrentMonth: true}
                ],
                [
                    {day: 17, selected: false, inCurrentMonth: true},
                    {day: 18, selected: false, inCurrentMonth: true},
                    {day: 19, selected: false, inCurrentMonth: true},
                    {day: 20, selected: false, inCurrentMonth: true},
                    {day: 21, selected: false, inCurrentMonth: true},
                    {day: 22, selected: false, inCurrentMonth: true},
                    {day: 23, selected: false, inCurrentMonth: true}
                ],
                [
                    {day: 24, selected: false, inCurrentMonth: true},
                    {day: 25, selected: false, inCurrentMonth: true},
                    {day: 26, selected: true, inCurrentMonth: true},
                    {day: 27, selected: false, inCurrentMonth: true},
                    {day: 28, selected: false, inCurrentMonth: true},
                    {day: 29, selected: false, inCurrentMonth: true},
                    {day: 30, selected: false, inCurrentMonth: true}
                ],
                [
                    {day: 31, selected: false, inCurrentMonth: true},
                    {day: 1, selected: false, inCurrentMonth: false},
                    {day: 2, selected: false, inCurrentMonth: false},
                    {day: 3, selected: false, inCurrentMonth: false},
                    {day: 4, selected: false, inCurrentMonth: false},
                    {day: 5, selected: false, inCurrentMonth: false},
                    {day: 6, selected: false, inCurrentMonth: false}
                ]
            ]

            expect(dateUtils.daysOfMonth).toEqual(expectedDaysOfMonth)
        })
    })

    describe('selectDay', () => {

        let otherDay = {day: 12, selected: false, inCurrentMonth: true}

        beforeEach(() => {
            dateUtils.selectDay(otherDay)
        })

        it('selects the day passed as argument', function () {
            const expectedDate = '2017-07-12'
            expect(dateUtils.dateString).toEqual(expectedDate)
        })
    })
})
