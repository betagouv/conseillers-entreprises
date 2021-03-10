import './insee_code_field'
import './semantic_ui_calendar_datepicker_params'
import './feedbacks'
import "./jquery-accessible-simple-tooltip-aria.js"
import './controllers'

import { Header } from "@gouvfr/header/src/scripts/header/header.js";

document.addEventListener("turbolinks:load", function () {
  console.log("hey");
  new Header();
});
