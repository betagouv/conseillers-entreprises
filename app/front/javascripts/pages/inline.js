// Ouvre la boite gestion des cookies au clic sur le lien
document.addEventListener("DOMContentLoaded", function() {
  const cookiesLink = document.getElementById("open-cookies-box")
  if (cookiesLink !== null) {
    cookiesLink.onclick = function() { tarteaucitron.userInterface.openPanel();return false };
  }
});
