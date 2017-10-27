import axios from 'axios'
import ErrorService from '../../common/errorService'

export default {
  getContactFromId (contactId) {
    var config = {
      method: 'get',
      url: `/api/contacts/${contactId}.json`
    }
    return this.send(config).then((response) => {
      return response.data
    })
  },

  createContactForVisit (visitId, contact) {
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
  },

  updateContact (contactId, contact) {
    var config = {
      method: 'patch',
      url: `/api/contacts/${contactId}.json`,
      data: {
        contact: contact
      }
    }
    return this.send(config).then((response) => {
      return true
    })
  },

  getVisitFromId (visitId) {
    var config = {
      method: 'get',
      url: `/api/visits/${visitId}.json`
    }
    return this.send(config).then((response) => {
      return response.data
    })
  },

  updateVisitDate (visitId, dateString) {
    /* eslint-disable camelcase */
    var config = {
      method: 'patch',
      url: `/api/visits/${visitId}.json`,
      data: {
        visit: {
          happened_on: dateString
        }
      }
    }
    /* eslint-enable camelcase */
    return this.send(config).then(() => {
      return true
    })
  },

  send (config) {
    return axios(config).catch((error) => {
      throw ErrorService.configureAPIErrorMessage(error, config)
    })
  }
}
