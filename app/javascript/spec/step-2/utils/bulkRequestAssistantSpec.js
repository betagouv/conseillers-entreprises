import BulkRequestAssistant from '../../../packs/step-2/utils/bulkRequestAssistant'

//for the async function to work
require('babel-core/register')

describe('BulkRequestAssistant', () => {

    describe('createBody', () => {
        const questions = [
            {
                id: 'q1',
                questionId: 1,
                questionLabel: 'LABEL or label ?',
                isSelected: true,
                diagnosedNeedId: undefined,
                content: 'This is content'
            },
            {
                id: 'q2',
                questionId: 2,
                questionLabel: 'Question ?',
                isSelected: true,
                diagnosedNeedId: 12,
                content: 'This is updated content. Maybe.'
            },
            {
                id: 'q3',
                questionId: 3,
                questionLabel: 'Whatever ?',
                isSelected: false,
                diagnosedNeedId: 23,
                content: 'Nooooooooo'
            },
            {
                id: 'q4',
                questionId: 4,
                questionLabel: 'LABEL !',
                isSelected: false,
                diagnosedNeedId: undefined,
                content: ''
            },
            {
                id: 'd111',
                questionId: undefined,
                questionLabel: 'LABEL !',
                isSelected: true,
                diagnosedNeedId: 111,
                content: 'Update an old thing'
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
                },
                {
                    id: 111,
                    content: 'Update an old thing'
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
            expect(requestBody).toEqual(expectedRequestBody)
        })
    })
})
