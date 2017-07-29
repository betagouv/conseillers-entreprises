import axios from 'axios'

export default class step2APIService {

    static updateDiagnosisContent(diagnosisId, content) {
        var config = {
            method: 'patch',
            url: `/api/diagnoses/${diagnosisId}`,
            data: {
                diagnosis: {
                    content: content
                }
            }
        }

        return this.send(config).then(() => {
            return true
        })
    }

    static createDiagnosedNeeds(diagnosisId, diagnosedNeeds) {
        var config = {
            method: 'post',
            url: `/api/diagnoses/${diagnosisId}/diagnosed_needs`,
            data: {
                diagnosed_needs: convertDiagnosedNeedsToAPIFormat(diagnosedNeeds)
            }
        }

        return this.send(config).then(() => {
            return true
        })
    }

    static send(config) {
        return axios(config)
    }
}

const convertDiagnosedNeedsToAPIFormat = function (diagnosedNeeds) {
    return diagnosedNeeds.map(function (diagnosedNeed) {
        return {
            question_id: diagnosedNeed.questionId,
            question_label: diagnosedNeed.questionLabel,
            content: diagnosedNeed.content
        }
    })
}