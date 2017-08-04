import moment from 'moment'

export default class DateValidator {
    constructor(stringDate) {
        this.stringDate = stringDate
        this.date = new moment(stringDate, ['DD/MM/YYYY','YYYY-MM-DD'], true)
    }

    get isEmpty() {
        return this.stringDate.length == 0
    }

    get isValid() {
        return this.date.isValid()
    }

    get toIsoString() {
        return this.isValid ? this.date.format('YYYY-MM-DD') : ''
    }
}