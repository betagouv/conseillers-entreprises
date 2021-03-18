import { Controller } from "stimulus";

export default class extends Controller {
  collapse() {
    let button = event.currentTarget;
    const collapsible = document.getElementById(
      button.getAttribute("aria-controls")
    );
    const state = button.getAttribute("aria-expanded");
    if (state == "true") {
      collapsible.style.setProperty("max-height", "");
      button.setAttribute("aria-expanded", false);
      collapsible.classList.remove("rf-collapse--expanded");
    } else {
      button.setAttribute("aria-expanded", true);
      collapsible.classList.add("rf-collapse--expanded");
      collapsible.style.setProperty("--collapser", "none");
      const height = collapsible.offsetHeight;
      collapsible.style.setProperty("--collapse", -height + "px");
      collapsible.style.setProperty("--collapser", "");
      collapsible.style.setProperty("max-height", "none");
    }
  }
}
