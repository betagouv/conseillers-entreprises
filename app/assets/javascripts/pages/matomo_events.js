// fonctions utilisées dans les vues directement
document.addEventListener("DOMContentLoaded", function() {
  const clickOnLanding = document.getElementsByClassName("click-on-landing")
  if (clickOnLanding.length !== 0) {
    Array.from(clickOnLanding).forEach(function (item) {
      item.addEventListener('click', function () {
        if (typeof _paq !== 'undefined') {
          _paq.push(['trackEvent', 'page-thematique', 'success'])
        }
      });
    });
  }

  const clickOnLandingSubject = document.getElementsByClassName("click-on-landing-subject")
  if (clickOnLandingSubject.length !== 0) {
    Array.from(clickOnLandingSubject).forEach(function (item) {
      item.addEventListener('click', function () {
        if (typeof _paq !== 'undefined') {
          _paq.push(['trackEvent', 'formulaire', 'success'])
        }
      });
    });
  }
});
