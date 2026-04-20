import { Controller } from "stimulus";

// See also views/applications/_questionnaire
// Display a notification modal, and let user mark the notification as read.
export default class extends Controller {
  connect() {
    console.assert(this.element.matches('dialog.fr-modal')) // this controller must be installed on the modal.

    setTimeout(() => {
      window.dsfr(this.element).modal.disclose()
    }, 1500);
  }

  mark({params: {key}}) {
    const csrfToken = document.querySelector("[name='csrf-token']").content

    fetch(`/app_info/${key}`, {
      method: "PUT",
      headers: { "X-CSRF-Token": csrfToken },
      credentials: "same-origin"
    })
      .then(() => { /* ignore */ })
  }
}
