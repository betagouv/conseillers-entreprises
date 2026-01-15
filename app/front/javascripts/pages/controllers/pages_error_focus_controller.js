import { Controller } from "stimulus";

export default class extends Controller {
  connect() {
    this.element.setAttribute('tabindex', '-1');
    this.element.focus();
  }
}
