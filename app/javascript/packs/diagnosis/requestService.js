import axios from 'axios'

export default class RequestService {
    constructor(defaultOnSuccess, defaultOnError) {
        this.defaultOnSuccess = defaultOnSuccess;
        this.defaultOnError = defaultOnError;
        this.axios = axios;
    }

    send(config, onSuccess = this.defaultOnSuccess , onError = this.defaultOnError) {
        this.axios(config).then(onSuccess).catch(onError)
    }
}