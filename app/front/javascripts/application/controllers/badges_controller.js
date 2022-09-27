import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [ 'form', 'list' ]

  toggle() {
    this.formTarget.classList.toggle("hide")
    this.listTarget.classList.toggle("hide")
  }
}
