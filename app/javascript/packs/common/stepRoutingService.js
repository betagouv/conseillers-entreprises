import axios from 'axios'

export default class StepRoutingService {
    constructor(diagnosisId) {
        this.diagnosisId = diagnosisId
    }

    go_to_step(step) {
        const config = {
            method: 'patch',
            url: `/api/diagnoses/${this.diagnosisId}`,
            data: {
                diagnosis: {
                    step: step
                }
            }
        }
        const url = `/diagnoses/${this.diagnosisId}/step-${step}`

        return StepRoutingService.send(config).then(() => {
            StepRoutingService.go_to(url)
        })
    }

    static send(config) {
        return axios(config)
    }

    static go_to(url) {
        Turbolinks.visit(url)
    }
}
