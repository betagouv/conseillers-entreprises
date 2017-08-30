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

    static updateDiagnosedNeeds(diagnosisId, diagnosedNeedBulkRequestBody) {
        var config = {
            method: 'post',
            url: `/api/diagnoses/${diagnosisId}/diagnosed_needs/bulk`,
            data: {
                bulk_params: diagnosedNeedBulkRequestBody
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
