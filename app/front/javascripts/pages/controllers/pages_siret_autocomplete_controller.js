import { Controller } from "stimulus";
import { exists, debounce } from '../../shared/utils.js'
import accessibleAutocomplete from 'accessible-autocomplete';

export default class extends Controller {
  static targets = [ "field", "loader", "siretField", "codeRegionField", "noResultLink" ]

  connect() {
    if (exists(this.fieldTarget.dataset.defaultValue)) {
      const siret = this.fieldTarget.dataset.defaultValue;
      document.querySelector('#query').value = siret;
      this.siretFieldTarget.value = parseInt(siret)
    }
    this.fieldTarget.addEventListener('input', () => {
      if (this.siretFieldTarget.value != this.fieldTarget.value) { this.siretFieldTarget.value = '' }
    })
  }

  initialize() {
    this.statusMessage = null;
    this.accessibleAutocomplete = accessibleAutocomplete({
      element: this.fieldTarget,
      id: this.fieldTarget.dataset.name,
      name: 'query',
      showNoOptionsFound: true,
      required: true,
      templates: {
        inputValue: this.inputValueTemplate,
        suggestion: this.suggestionTemplate
      },
      tNoResults: () => this.statusMessage,
      tAssistiveHint: () => this.fieldTarget.dataset.assistiveHint,
      tStatusNoResults: () => this.statusMessage,
      tStatusSelectedOption: (selectedOption, length, index) => `${selectedOption} ${index + 1} sur ${length} est sélectionné`,
      tStatusResults: (length, contentSelectedOption) => {
        const baseSentence = (length === 1) ? "1 résultat trouvé" : `${length} résultats trouvés`
        return `${baseSentence}. ${contentSelectedOption}`
      },
      source: debounce(async (query, populateResults) => {
        const results = await this.fetchEtablissements(query);
        if(!results) return;
        if (results.error) {
          this.manageSourceError(results)
        } else {
          this.manageSourceSuccess(results.items)
          populateResults(this.filterResults(results.items))
        }
      }, 300),
      onConfirm: (option) => {
        this.onConfirm(option)
      }
    })
  }

  manageSourceError(results) {
    this.loaderTarget.style.display = 'none'
    this.noResultLinkTarget.style.display = 'block'
    this.statusMessage = results.error
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

  onConfirm(option) {
    if (option) {
      this.fillCodeRegionField(option.code_region);
      this.fillSiretField(option);
    }
  }

  async fetchEtablissements(query) {
    this.loaderTarget.style.display = 'block'
    let baseUrl = this.fieldTarget.dataset.url
    let params = `query=${query}`;
    let response = await fetch(`${baseUrl}.json?${params}`, {
      credentials: "same-origin",
    });
    try {
      let data = await response.json();
      return data;
    } catch(err) {
      this.manageSourceError({error: "Problème de réception des données, veuillez réessayer avec d'autres paramètres"})
    }
  }

  filterResults(data) {
    return data.filter((etablissement) => {
      // Remove Administrations from suggestions
      return etablissement.activite != "Administration publique générale";
    });
  }

  fillSiretField(result) {
    if (result) {
      let value = result.un_seul_etablissement == true ? result.siret : result.siren
      this.siretFieldTarget.value = parseInt(value)
    }
  }

  fillCodeRegionField(code_region) {
    if (code_region) {
      this.codeRegionFieldTarget.value = parseInt(code_region)
    }
  }

  suggestionTemplate (result) {
    if (!result) return
    if (result.un_seul_etablissement == false) {
      return (
        result &&
        `<strong> ${result.siren} (${result.nom}) </strong>
          <p><span class="small">${result.activite || ''}</span> </p>`
      );
    } else {
      return (
        result &&
        `<strong> ${result.siret} (${result.nom}) </strong>
          <p><span class="small">${result.activite || ''} - ${result.lieu || ''}</span> </p>`
      );
    }
  }

  inputValueTemplate (result) {
    if (!result) return null
    return (result.un_seul_etablissement == true ? result.siret : result.siren)
  }
}
