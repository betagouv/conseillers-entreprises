import axios from 'axios'

export default class RequestService {
    constructor(defaultOnSuccess, defaultOnError) {
        this.defaultOnSuccess = defaultOnSuccess;
        this.defaultOnError = defaultOnError;
        this.axios = axios;
    }

    send(config, onSuccess = this.defaultOnSuccess , onError = this.defaultOnError) {
        const token = document.getElementsByName('csrf-token')[0].getAttribute('content')
        config.headers = {
            'X-CSRF-Token': token,
            'Accept': 'application/json'
        }
        this.axios(config).then(onSuccess).catch(onError)
    }
}