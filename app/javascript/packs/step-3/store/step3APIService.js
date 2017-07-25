import axios from 'axios'

export default class step3APIService {

    static send(config) {
        return axios(config)
    }
}