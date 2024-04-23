import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [  ]

  connect() {
    // eslint-disable-next-line no-undef
    dsfr(this.element).modal.disclose()
    this.element.addEventListener('dsfr.conceal', () => {
      this.markAsSeen();
    })
  }

  async markAsSeen() {
    let url = this.element.dataset.url
    await fetch(url, {
      credentials: "same-origin"
    })
  }
}
