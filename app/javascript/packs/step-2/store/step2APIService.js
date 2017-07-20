import axios from 'axios'

export default class step2APIService {

    static udpateDiagnosisContent(diagnosisId, content) {
        var config = {
            method: 'patch',
            url: `/api/diagnoses/${diagnosisId}`,
            data: {
                diagnosis: {
                    content: 'Awesome random stuff'
                }
            }
        };
        return this.send(config).then(() => {
            return true;
        });
    }

    static send(config) {
        return axios(config)
    }
}