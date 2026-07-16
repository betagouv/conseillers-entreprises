import { Controller } from "stimulus";
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  submit(event) {
    if (event.target.form) {
      event.target.form.requestSubmit()
    } else if (event.target?.selectedOptions?.item(0)?.dataset?.directSubmitUrl !== undefined) {
      Turbo.visit(event.target.selectedOptions.item(0).dataset.directSubmitUrl)
    }
  }
}
