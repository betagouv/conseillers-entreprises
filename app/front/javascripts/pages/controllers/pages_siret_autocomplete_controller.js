import { exists } from '../../shared/utils.js'
import  SiretAutocompleteController from "../../shared/controllers/siret_autocomplete_controller.js"


export default class extends SiretAutocompleteController {
  static targets = [ "field", "codeRegionField", "siretField", "unSeulEtablissementField", "loader" ]

  connect() {
    if (exists(this.fieldTarget.dataset.defaultValue)) {
      const siret = this.fieldTarget.dataset.defaultValue;
      document.querySelector('#query').value = siret;
      this.fillSiretField(siret);
    }
  }

  manageSourceError(results) {
    console.warn(results.error)
  }

  manageSourceSuccess() {
    console.log("success")
  }

  onConfirm(option) {
    if (option) {
      this.fillCodeRegionField(option.code_region);
      this.fillSiretField(option.siret);
    }
  }

  // Récupération des résultats ----------------------------------------------------

  displayNonDiffusableSiret() {
    return false;
  }

  // Traitement des résultats --------------------------------------------

  fillCodeRegionField(code_region) {
    if (code_region) {
      this.codeRegionFieldTarget.value = parseInt(code_region)
    }
  }

  fillSiretField(siret) {
    if (siret) {
      this.siretFieldTarget.value = parseInt(siret)
    }
  }
}
