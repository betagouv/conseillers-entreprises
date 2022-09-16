import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [ "blockContent" ]

  close() {
    document.cookie = "bandeau_info_read=true; path=/";
    this.blockContentTarget.remove()
  }
}
