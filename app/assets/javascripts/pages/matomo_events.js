// fonction utilisées dans les vues directement
document.addEventListener("DOMContentLoaded", function() {
  const clickOnLanding = document.getElementsByClassName("click-on-landing")
  if (clickOnLanding.length !== 0) {
    clickOnLanding.forEach(function (item) {
      item.addEventListener('click', function () {
        if (typeof _paq !== 'undefined') {
          _paq.push(['trackEvent', 'page-thematique', 'success'])
        }
      });
    });
  }

  const clickOnLandingOption = document.getElementsByClassName("click-on-landing-option")
  if (clickOnLandingOption.length !== 0) {
    clickOnLandingOption.forEach(function (item) {
      item.addEventListener('click', function () {
        if (typeof _paq !== 'undefined') {
          _paq.push(['trackEvent', 'formulaire', 'success'])
        }
      });
    });
  }
});
