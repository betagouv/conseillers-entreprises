import TraceKit from 'tracekit'
import axios from 'axios'

TraceKit.report.subscribe(function yourLogger(errorReport) {
    console.log(' >  Tracekit')
    console.log(errorReport)
})

export default {
    configureFramework(Vue) {
        Vue.config.errorHandler = function (err, vm, info) {
            TraceKit.report(err)
        }
    },

    report(error) {
        TraceKit.report(error)
    },

    send(config) {
        axios(config)
    },

    configureAPIErrorMessage(error, config) {
        const errorMessage = `API ${config.method} call request to: ${config.url} | `
        error.message = errorMessage + error.message
        return error
    }
}