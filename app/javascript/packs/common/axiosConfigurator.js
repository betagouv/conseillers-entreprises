import axios from 'axios'

export default {
  configure: function () {
    var token
    try {
      token = document.getElementsByName('csrf-token')[0].getAttribute('content')
    } catch (e) {
      token = ''
    }
    axios.defaults.headers.common['X-CSRF-Token'] = token
    axios.defaults.headers.common['Accept'] = 'application/json'
  }
}
