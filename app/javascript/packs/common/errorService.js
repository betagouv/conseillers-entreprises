import TraceKit from 'tracekit'
import axios from 'axios'

export {ErrorService as default}

TraceKit.report.subscribe((errorReport) => {
    ErrorService.sendErrorReport(errorReport)
})

let ErrorService = {

    configureFramework: function (Vue) {
        Vue.config.errorHandler = function (err, vm, info) {
            TraceKit.report(err)
        }
    },

    report: function (error) {
        TraceKit.report(error)
    },

    sendErrorReport: function (errorReport) {
        const config = {
            method: 'post',
            url: '/api/errors',
            data: {
                error_report: errorReport
            }
        }

        this.send(config)
    },

    send: function (config) {
        axios(config)
    },

    configureAPIErrorMessage: function (error, config) {
        const errorMessageIntroduction = `API ${config.method} call request to: ${config.url} | `
        error.message = errorMessageIntroduction + error.message
        return error
    }
}
