import QuestionObjectParser from '../../../packs/step-2/utils/questionObjectParser'

//for the async function to work
require('babel-core/register')

describe('QuestionObjectParser ', () => {

    describe('parse', () => {
        const rawString = JSON.stringify({
            question_id: 12345,
            label: 'LABEL or label',
            is_selected: false,
            content: null
        })

        const expectedQuestion = {
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
})
