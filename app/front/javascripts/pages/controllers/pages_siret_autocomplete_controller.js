import { exists } from '../../shared/utils.js'
import  SiretAutocompleteController from "../../shared/controllers/siret_autocomplete_controller.js"


export default class extends SiretAutocompleteController {
  static targets = [ "field", "loader", "codeRegionField", "siretField", "unSeulEtablissementField", "noResultLink" ]

  connect() {
    if (exists(this.fieldTarget.dataset.defaultValue)) {
      const siret = this.fieldTarget.dataset.defaultValue;
      document.querySelector('#query').value = siret;
      this.fillSiretField(siret);
    }
  }

  onConfirm(option) {
    if (option) {
      this.fillCodeRegionField(option.code_region);
      this.fillSiretField(option.siret);
    }
  }

  manageSourceSuccess(items) {
    this.loaderTarget.style.display = 'none'
    if (items.length == 0) {
      this.noResultLinkTarget.style.display = 'block'
      this.statusMessage = "Aucune entreprise trouvée"
    } else {
      this.statusMessage = null
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
