import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [ "cardCheckbox", "button", "allCheckbox" ]

  connect() {
    this.verifyChecked()
  }

  toggleAll() {
    for(let checkbox of this.cardCheckboxTargets) {
      checkbox.checked = this.allCheckboxTarget.checked
    }
    this.verifyChecked()
  }
  
  verifyChecked() {
    let checked = this.cardCheckboxTargets.filter((checkbox) => checkbox.checked)
    if (checked.length > 0) {
      this.buttonTarget.removeAttribute("disabled");
    } else {
      this.buttonTarget.setAttribute("disabled", true);
    }
  }
}
