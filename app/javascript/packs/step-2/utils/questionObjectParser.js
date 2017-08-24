export default  {
    parse(rawJsonString) {
        const rawJson = JSON.parse(rawJsonString)
        return {
            questionId: rawJson.question_id,
            label: rawJson.label,
            isSelected: rawJson.is_selected,
            diagnosedNeedId: rawJson.diagnosed_need_id || undefined,
            content: rawJson.content || ''
        }
    }
}