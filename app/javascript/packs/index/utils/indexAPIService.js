import axios from 'axios'

export default {
    fetchCompany: function (siret) {
        var config = {
            method: 'post',
            url: `/api/facilities/search_by_siret`,
            data: {
                siret: siret
            }
        }

        return this.send(config).then((response) => {
            return response.data
        })
    },

    send: function (config) {
        return axios(config)
    }
}
