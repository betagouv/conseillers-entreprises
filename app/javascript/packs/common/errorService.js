import TraceKit from 'tracekit'
import axios from 'axios'

const ErrorService = {

  configureFramework: function (Vue) {
    Vue.config.errorHandler = function (err, vm, info) {
      TraceKit.report(err)
    }
  },

  report: function (error) {
    TraceKit.report(error)
  },

  sendErrorReport: function (errorReport) {
    /* eslint-disable camelcase */
    const config = {
      method: 'post',
      url: '/api/errors',
      data: {
        error_report: errorReport
      }
    }
    /* eslint-enable camelcase */
    this.send(config)
  },

  send: function (config) {
    axios(config)
  },

  configureAPIErrorMessage: function (error, config) {
    const errorMessageIntroduction = `API ${config.method} call request to: ${config.url}`
    error.message = `${errorMessageIntroduction} | ${error.message}`
    return error
  }
}

export { ErrorService as default }

TraceKit.report.subscribe((errorReport) => {
  ErrorService.sendErrorReport(errorReport)
})
