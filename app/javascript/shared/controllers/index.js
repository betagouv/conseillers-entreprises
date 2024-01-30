import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";

const application = Application.start();
const context = require.context("javascript/shared/controllers", true, /\.js$/);
application.load(definitionsFromContext(context));
