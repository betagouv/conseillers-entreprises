import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["mobileMenu", "blockMenu"];

  toggleMobileMenu() {
    this.mobileMenuTarget.classList.toggle("hidden");
  }

  openBlockMenu(event) {
    event.target.classList.add("active");
    this.blockMenuTarget.classList.remove("hidden");
  }

  closeBlockMenu(event) {
    event.target.classList.remove("active");
    this.blockMenuTarget.classList.add("hidden");
  }

  connect() {
    console.log("Main menu connect");
  }
}
