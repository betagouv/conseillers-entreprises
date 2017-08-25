export default {
    createBody(questions) {
        return questions.reduce(function (requestBody, question) {

            if (shouldCreate(question)) {
                requestBody.create.push(paramForCreate(question))
            }
            if (shouldUpdate(question)) {
                requestBody.update.push(paramForUpdate(question))
            }
            if (shouldDelete(question)) {
                requestBody.delete.push(paramForDelete(question))
            }
            return requestBody
        }, {create: [], update: [], delete: []})
    }
}

function shouldCreate(question) {
    return question.isSelected && !question.diagnosedNeedId
}

function shouldUpdate(question) {
    return question.isSelected && question.diagnosedNeedId
}

function shouldDelete(question) {
    return !question.isSelected && question.diagnosedNeedId
}

function paramForCreate(question) {
    return {
        question_id: question.questionId,
        question_label: question.label,
        content: question.content
    }
}

function paramForUpdate(question) {
    return {
        id: question.diagnosedNeedId,
        content: question.content
    }
}

function paramForDelete(question) {
    return {
        id: question.diagnosedNeedId
    }
}
