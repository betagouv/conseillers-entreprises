(function () {
  addEventListener("DOMContentLoaded", setupToggleNavButton);

  function setupToggleNavButton() {
    let ToggleNavButton = document.querySelector("[data-action='toggle-nav']");
    let nav = document.querySelector("[data-target='toggle-nav']")
    ToggleNavButton.addEventListener("click", (event) => {
      event.preventDefault();
      if (!nav.classList.contains('active')) {
        nav.classList.add('active');
      } else {
        nav.classList.remove('active');
      }
    }, false);
  }
})();
