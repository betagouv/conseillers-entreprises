import { Controller } from "stimulus";
import { exists, debounce } from '../../shared/utils.js'
import accessibleAutocomplete from 'accessible-autocomplete';

export default class extends Controller {
  static targets = [ "field" ]

  initialize() {
    console.log('initialize')

    this.accessibleAutocomplete = accessibleAutocomplete({
      element: this.fieldTarget,
      id: 'solicitation-siret',
      name: 'query',
      showNoOptionsFound: true,
      templates: {
        inputValue: this.inputValueTemplate,
        suggestion: this.suggestionTemplate
      },
      // defaultValue: this.fieldTarget.dataset.defaultValue,
      source: debounce(async (query, populateResults) => {
        console.log(query)
        // reinitFormFields(query);
        const results = await this.fetchEtablissements(query);
        console.log(results)
        if(!results) return;
        if (results.error) {
          console.warn(results.error)
          // displayErrorBlock()
        } else {
          // hideErrorBlock()
          populateResults(this.filterResults(results));
        }
      }, 300),
      onConfirm: (option) => {
        console.log(option)
        // fillSiretField(option)
      }
    })
  }

  connect() {
    console.log('connect')
    console.log(this.fieldTarget.dataset.defaultValue)
    console.log(this.fieldTarget.value)
    if (exists(this.fieldTarget.dataset.defaultValue)) {
      document.querySelector('#solicitation-siret').value = this.fieldTarget.dataset.defaultValue
    }

    // this.toggleField()
  }

  // Récupération des résultats ----------------------------------------------------

  async fetchEtablissements(query) {
    let params = `query=${query}`;
    let response = await fetch(`/rech-etablissement?${params}`, {
      credentials: "same-origin",
    });
    let data = await response.json();
    return data;
  }

  filterResults(data) {
    return data.filter((etablissement) => {
      // remove Administrations from suggestions
      return etablissement.activite != "Administration publique générale";
    });
  }

  // Traitement des résultats --------------------------------------------

  suggestionTemplate (result) {
    if (!result) return
    return (
      result &&
      `<strong> ${result.siret} (${result.nom}) </strong>
        <p><span class="small">${result.activite || ''} - ${result.lieu || ''}</span> </p>`
    );
  }

  inputValueTemplate (result) {
    return result && result.siret;
  }
}
