import axios from 'axios'

export default class ContactAPIService {

    static createContactOnVisit(visitId, contact) {
        var config = {
            method: 'post',
            url: `/api/visits/${visitId}/contacts.json`,
            data: {
                contact: contact
            }
        };
        return this.send(config).then( (reponse) => {
            return response.data
        });
    }

    static send(config) {
        return axios(config)
    }
}