import { Controller } from "stimulus";
import { exists, debounce } from '../utils.js'
import accessibleAutocomplete from 'accessible-autocomplete';

export default class extends Controller {
  static targets = [ "field", "loader" ]

  initialize() {
    this.accessibleAutocomplete = accessibleAutocomplete({
      element: this.fieldTarget,
      id: this.fieldTarget.dataset.name,
      name: 'solicitation[siret]',
      showNoOptionsFound: false,
      templates: {
        inputValue: this.inputValueTemplate,
        suggestion: this.suggestionTemplate
      },
      tAssistiveHint: () => this.fieldTarget.dataset.assistiveHint,
      source: debounce(async (query, populateResults) => {
        const results = await this.fetchEtablissements(query);
        if(!results) return;
        if (results.error) {
          this.manageSourceError(results)
        } else {
          this.manageSourceSuccess(results)
          populateResults(this.filterResults(results.items))
        }
      }, 300),
      onConfirm: (option) => {
        this.onConfirm(option)
      }
    })
  }

  connect() {
    if (exists(this.fieldTarget.dataset.defaultValue)) {
      document.querySelector('#solicitation-siret').value = this.fieldTarget.dataset.defaultValue
    }
  }

  manageSourceError(results) {
    console.warn(results.error)
  }

  manageSourceSuccess() {
    // here, do nothing. Check children
  }

  onConfirm() {
    // here, do nothing. Check children
  }

  // Récupération des résultats ----------------------------------------------------

  async fetchEtablissements(query) {
    this.loaderTarget.style.display = 'block'
    let baseUrl = this.fieldTarget.dataset.url
    let params = `query=${query}&non_diffusables=${this.displayNonDiffusableSiret()}`;
    let response = await fetch(`${baseUrl}.json?${params}`, {
      credentials: "same-origin",
    });
    // Au cas où autre chose que du json est renvoyé
    try {
      let data = await response.json();
      this.loaderTarget.style.display = 'none'
      return data;
    } catch(err) {
      this.loaderTarget.style.display = 'none'
      // eslint-disable-next-line no-undef
      Sentry.captureException(err)
      this.manageSourceError({error: "error reading not json data"})
    }
  }

  filterResults(data) {
    return data.filter((etablissement) => {
      // remove Administrations from suggestions
      return etablissement.activite != "Administration publique générale";
    });
  }

  displayNonDiffusableSiret() {
    return true;
  }

  // Traitement des résultats --------------------------------------------

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
    if (!result) return
    return (result.un_seul_etablissement == true ? result.siret : result.siren)
  }
}
