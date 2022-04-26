import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [ "checkboxes" ]


  autoUncheck(event) {
    let currentCheckbox = event.currentTarget
    if (this.isNotAutoUncheckable(currentCheckbox)) {
      for(let checkbox of this.uncheckableCheckboxes()) {
        checkbox.checked = false
      }
    }
  }

  isNotAutoUncheckable(checkbox) {
    return checkbox.dataset.uncheck == "false"
  }

  uncheckableCheckboxes() {
    return this.checkboxesTargets.filter(e => e.dataset.uncheck == 'true')
  }

}
