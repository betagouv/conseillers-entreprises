import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [  ]

  connect() {
    dsfr(this.element).modal.disclose()
    this.element.addEventListener('dsfr.conceal', (e) => {
      this.markAsSeen();
  })
  }

  async markAsSeen() {
    console.log("markAsSeen")
    let url = this.element.dataset.url
    const response = await fetch(url, {
      credentials: "same-origin"
    })
  }
}
