import axios from 'axios'
import he from 'he'

export default class ContactAPIService {
  static createContactOnVisit (visitId, contact) {
    var config = {
      method: 'post',
      url: `/api/visits/${visitId}/contacts.json`,
      data: {
        contact: contact
      }
    }
    return this.send(config).then((response) => {
      return response.data
    })
  }

  static getExpertEmailButton (visitId, assistanceId, expertId) {
    var config = {
      method: 'get',
      url: '/api/contacts/contact_button_expert.json',
      params: {
        visit_id: visitId,
        assistance_id: assistanceId,
        expert_id: expertId
      }
    }
    return this.send(config).then((response) => {
      return he.decode(response.data.html)
    })
  }

  static getContacts (visitId) {
    var config = {
      method: 'get',
      url: `/api/visits/${visitId}/contacts.json`
    }
    return this.send(config).then((response) => {
      return response.data
    })
  }

  static send (config) {
    return axios(config)
  }
}
