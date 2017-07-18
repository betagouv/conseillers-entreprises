import axios from 'axios'

export default class ContactAPIService {

    static createContactOnVisit(visitId, contact) {
        var config = {
            method: 'posSt',
            url: `/api/visits/${visitId}/contacts.json`,
            data: {
                contact: contact
            }
        };
        this.send(config);
    }

    static send(config) {
        return axios(config)
    }
}