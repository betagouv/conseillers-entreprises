export default  {
    parse(rawJsonString) {
        const rawJson = JSON.parse(rawJsonString)
        return {
            id: generateId(rawJson.question_id, rawJson.diagnosed_need_id),
            questionId: rawJson.question_id,
            label: rawJson.label,
            isSelected: rawJson.is_selected,
            diagnosedNeedId: rawJson.diagnosed_need_id || undefined,
            content: rawJson.content || ''
        }
    },

    transformDiagnosedNeed(rawJson) {
        return {
            id: generateId(rawJson.question_id, rawJson.id),
            questionId: rawJson.question_id,
            isSelected: true,
            diagnosedNeedId: rawJson.id,
            content: rawJson.content || ''
        }
    }
}

function generateId(questionId, diagnosisId) {
    if(new Number(questionId) == questionId) {
        return `q${questionId}`
    } else {
        return `d${diagnosisId}`
    }
}