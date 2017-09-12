import axios from 'axios'

export default {
    createDiagnosis(siret) {
        var config = {
            method: 'post',
            url: '/api/diagnoses',
            data: {
                siret: siret
            }
        }

        return this.send(config).then((response) => {
            return response.data.id
        })
    },

    send(config) {
        return axios(config)
    }
}
