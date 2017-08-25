import BulkRequestAssistant from '../../../packs/step-2/utils/bulkRequestAssistant'

//for the async function to work
require('babel-core/register')

describe('BulkRequestAssistant', () => {

    describe('createBody', () => {
        const questions = [
            {
                questionId: 1,
                label: 'LABEL or label ?',
                isSelected: true,
                diagnosedNeedId: undefined,
                content: 'This is content'
            },
            {
                questionId: 2,
                label: 'Question ?',
                isSelected: true,
                diagnosedNeedId: 12,
                content: 'This is updated content. Maybe.'
            },
            {
                questionId: 3,
                label: 'Whatever ?',
                isSelected: false,
                diagnosedNeedId: 23,
                content: 'Nooooooooo'
            },
            {
                questionId: 4,
                label: 'LABEL !',
                isSelected: false,
                diagnosedNeedId: undefined,
                content: ''
            }
        ]

        const expectedRequestBody = {
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

        it('creates the expected request body object', function () {
            const requestBody = BulkRequestAssistant.createBody(questions)
            console.log(`requestBody ${JSON.stringify(requestBody)}`)
            expect(requestBody).toEqual(expectedRequestBody)
        })
    })
})
