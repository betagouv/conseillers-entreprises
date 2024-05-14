import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [  ]

  connect() {
    // eslint-disable-next-line no-undef
    setTimeout(() => {
      const modalElement = this.element
      if (modalElement && window.dsfr(modalElement)) {
        window.dsfr(modalElement).modal.disclose();
        modalElement.addEventListener('dsfr.conceal', () => {
          this.markAsSeen();
        })
      }
    }, 1500);
  }

  async markAsSeen() {
    let url = this.element.dataset.url
    await fetch(url, {
      credentials: "same-origin"
    })
  }
}
