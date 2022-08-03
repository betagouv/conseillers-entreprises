import { exists } from '../../shared/utils.js'
import  SiretAutocompleteController from "../../shared/controllers/siret_autocomplete_controller.js"


export default class extends SiretAutocompleteController {
  static targets = [ "field", "codeRegionField", "siretField", "unSeulEtablissementField" ]

  connect() {
    for (const el of document.getElementsByClassName( 'no-js-only' )) { el.style.display = "none" }
    for (const el of document.getElementsByClassName( 'with-js-only' )) { el.style.display = "block" }
  }

  manageSourceError(results) {
    console.warn(results.error)
  }

  manageSourceSuccess() {
    console.log("success")
  }

  onConfirm(option) {
    this.fillCodeRegionField(option);
    this.fillSiretField(option);
    this.fillUnSeulEtablissementField(option);
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

  fillSiretField(option) {
    if (option && option.siret) {
      this.fieldTarget.value = parseInt(option.siret)
    }
  }

  fillUnSeulEtablissementField(option) {
    if (option && exists(option.un_seul_etablissement)) {
      this.unSeulEtablissementFieldTarget.value = !!option.un_seul_etablissement
    }
  }

  fillNewsletterForm() {
    const solicitation_form_email = document.getElementById("solicitation_email")
    const newsletter_form_email = document.getElementById("email")
    newsletter_form_email.value = solicitation_form_email.value
  }

}
