import axios from 'axios'

export default class StepRoutingService {
    constructor(diagnosisId) {
        this.diagnosisId = diagnosisId
    }

    goToStep(step) {
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
            StepRoutingService.goTo(url)
        })
    }

    static send(config) {
        return axios(config)
    }

    static goTo(url) {
        Turbolinks.clearCache()
        Turbolinks.visit(url)
    }
}
