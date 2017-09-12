import TraceKit from 'tracekit'
import Vue from 'vue/dist/vue.esm'
import axios from 'axios'

export default {
    configure() {
        Vue.config.errorHandler = function (err, vm, info) {
            TraceKit.report(err)
        }

        TraceKit.report.subscribe(function yourLogger(errorReport) {
            console.log(' >  Tracekit')
            console.log(errorReport)
        })
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