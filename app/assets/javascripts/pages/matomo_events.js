// fonctions utilisées dans les vues directement
document.addEventListener('turbo:load', function() {
  const clickOnLanding = document.getElementsByClassName("click-on-landing")
  if (clickOnLanding.length !== 0) {
    Array.from(clickOnLanding).forEach(function (item) {
      item.addEventListener('click', function () {
        if (typeof _paq !== 'undefined') {
          _paq.push(['trackEvent', 'page-thematiques', 'success'])
        }
      });
    });
  }
  const clickOnLandingTheme = document.getElementsByClassName("click-on-landing-theme")
  if (clickOnLandingTheme.length !== 0) {
    Array.from(clickOnLandingTheme).forEach(function (item) {
      item.addEventListener('click', function () {
        if (typeof _paq !== 'undefined') {
          _paq.push(['trackEvent', 'page-sujets', 'success'])
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
