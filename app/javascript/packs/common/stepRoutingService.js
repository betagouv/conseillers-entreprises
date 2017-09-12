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

        return StepRoutingService.send(config)
            .then(() => {
                StepRoutingService.goTo(url)
            })
            .catch((error) => {
                throw this.configureErrorForURL(error, url)
            })
    }

    configureErrorForURL(error, url) {
        const errorMessage = `StepRoutingService request to: ${url} | `
        error.message = errorMessage + error.message
        return error
    }

    static send(config) {
        return axios(config)
    }

    static goTo(url) {
        Turbolinks.clearCache()
        Turbolinks.visit(url)
    }
}
