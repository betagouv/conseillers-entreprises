import { exists } from "../shared/utils.js";

(function () {
  addEventListener("DOMContentLoaded", setupToggleNavButton);

  function setupToggleNavButton() {
    let ToggleNavButton = document.querySelector("[data-action='toggle-nav']");
    let nav = document.querySelector("[data-target='toggle-nav']")
    if (exists(ToggleNavButton) && exists(nav)) {
      ToggleNavButton.addEventListener("click", (event) => {
        event.preventDefault();
        nav.classList.toggle('active');
      }, false);
    }
  }
})();
