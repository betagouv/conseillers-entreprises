// import { Application } from '@hotwired/stimulus';
// import { definitionsFromContext } from "stimulus/webpack-helpers";

// const application = Application.start();
// const context = require.context("javascript/shared/controllers", true, /\.js$/);
// application.load(definitionsFromContext(context));


import '@hotwired/turbo-rails'
import { Application } from '@hotwired/stimulus'

// General Controllers
// -------------------
// import all Stimulus controller files under the controllers folder
import controllers from './*_controller.js'

// Auxiliary Methods
// -----------------
// Infer Stimulus controller name from its file
function controllerName(defaultName) {
  const namespaces = [
    ...new Set(
      defaultName
        .split('--')
        .filter((ns) => !['..', 'controllers'].includes(ns))
    )
  ]
  return namespaces.join('--')
}

const application = Application.start()

// Set flag to true to get debbug information in the web browser console
application.debug = true
window.Stimulus = application

controllers.forEach((controller) => {
  Stimulus.register(controllerName(controller.name), controller.module.default)
})
