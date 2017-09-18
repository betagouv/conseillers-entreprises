export default {
  parse (rawJsonString) {
    const rawJson = JSON.parse(rawJsonString)
    /* eslint-disable camelcase */
    return {
      id: generateId(rawJson.question_id, rawJson.diagnosed_need_id),
      questionId: rawJson.question_id,
      label: rawJson.label,
      isSelected: rawJson.is_selected,
      diagnosedNeedId: rawJson.diagnosed_need_id || undefined,
      content: rawJson.content || ''
    }
    /* eslint-enable camelcase */
  },

  transformDiagnosedNeed (rawJson) {
    return {
      id: generateId(rawJson.question_id, rawJson.id),
      questionId: rawJson.question_id,
      isSelected: true,
      diagnosedNeedId: rawJson.id,
      content: rawJson.content || ''
    }
  }
}

function generateId (questionId, diagnosisId) {
  if (Number(questionId) === questionId) {
    return `q${questionId}`
  } else {
    return `d${diagnosisId}`
  }
}
