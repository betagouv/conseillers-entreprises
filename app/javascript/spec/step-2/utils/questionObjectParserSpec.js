import QuestionObjectParser from '../../../packs/step-2/utils/questionObjectParser'

//for the async function to work
require('babel-core/register')

describe('QuestionObjectParser ', () => {

    describe('parse', () => {
        describe('there is a question id', () => {
            const rawString = JSON.stringify({
                question_id: 12345,
                label: 'LABEL or label',
                is_selected: false,
                content: null
            })

            const expectedQuestion = {
                id: 'q12345',
                questionId: 12345,
                label: 'LABEL or label',
                isSelected: false,
                diagnosedNeedId: undefined,
                content: ''
            }

            it('creates the expected object', function () {
                const question = QuestionObjectParser.parse(rawString)
                expect(question).toEqual(expectedQuestion)
            })
        })

        describe('there is no question id', () => {
            const rawString = JSON.stringify({
                question_id: undefined,
                label: 'LABEL or label',
                is_selected: false,
                diagnosed_need_id: 9876,
                content: null
            })

            const expectedQuestion = {
                id: 'd9876',
                questionId: undefined,
                label: 'LABEL or label',
                isSelected: false,
                diagnosedNeedId: 9876,
                content: ''
            }

            it('creates the expected object', function () {
                const question = QuestionObjectParser.parse(rawString)
                expect(question).toEqual(expectedQuestion)
            })
        })
    })
})
