import  SiretAutocompleteController from "../../shared/controllers/siret_autocomplete_controller.js"

export default class extends SiretAutocompleteController {
  static targets = [ "field", "codeRegionField", "indifusibleBlock", "undeployedRegionBlock" ]

  manageSourceError() {
    this.indifusibleBlockTarget.style.display = "block";
  }

  manageSourceSuccess() {
    this.indifusibleBlockTarget.style.display = "none";
  }

  onConfirm(option) {
    this.fillCodeRegionField(option)
    if (this.fieldTarget.dataset.landingTheme !== 'environnement-transition-ecologique') {
      this.checkIfInDeployedRegion(option)
    }
  }

  // Récupération des résultats ----------------------------------------------------

  displayNonDiffusableSiret() {
    return false;
  }

  // Traitement des résultats --------------------------------------------

  fillCodeRegionField(option) {
    if (option && option.code_region) {
      this.codeRegionFieldTarget.value = parseInt(option.code_region)
    }
  }

  checkIfInDeployedRegion (option) {
    if (option && option.code_region) {
      let codeRegion = parseInt(option.code_region);
      if (!this.codeRegionFieldTarget.dataset.deployedRegions.includes(codeRegion)) {
        this.undeployedRegionBlockTarget.style.display = 'block'
        this.fillNewsletterForm()
      }
    }
  }

  fillNewsletterForm() {
    const solicitation_form_email = document.getElementById("solicitation_email")
    const newsletter_form_email = document.getElementById("email")
    newsletter_form_email.value = solicitation_form_email.value
  }

}
