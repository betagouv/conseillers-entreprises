import { exists, debounce } from '../shared/utils.js'
import accessibleAutocomplete from 'accessible-autocomplete';

(function () {
  addEventListener('DOMContentLoaded', setupSiretAutocomplete)

  function setupSiretAutocomplete () {
    const autocompleteField = document.querySelector("[data-action='siret-autocomplete']")
    if (autocompleteField === null) return

    const deployedRegion = autocompleteField.getAttribute('data-deployed-regions')
    const siretField = document.querySelector("[data-target='siret-autocomplete']")
    const codeRegionField = document.querySelector("[data-target='code-region-autocomplete']")
    const indifusibleSiretHelp = document.querySelector("[data-error='indiffusible-siret']")

    if (exists(autocompleteField)) {
      accessibleAutocomplete({
        element: autocompleteField,
        id: 'solicitation_siret_autocomplete',
        showNoOptionsFound: false,
        templates: {
          inputValue: inputValueTemplate,
          suggestion: suggestionTemplate
        },
        tAssistiveHint: () => autocompleteField.dataset.assistiveHint,
        source: debounce(async (query, populateResults) => {
          reinitFormFields(query);
          const results = await fetchEtablissements(query);
          if(!results) return;
          if (results.error) {
            displayErrorBlock()
          } else {
            hideErrorBlock()
            populateResults(filterResults(results));
          }
        }, 300),
        onConfirm: (option) => {
          fillSiretField(option)
          fillCodeRegionField(option)
          checkIfInDeployedRegion(option)
        }
      })
    }

    function fillSiretField(option) {
      if (option && option.siret) {
        siretField.value = option.siret
      }
    }

    function fillCodeRegionField(option) {
      if (option && option.code_region) {
        codeRegionField.value = option.code_region
      }
    }

    function checkIfInDeployedRegion (option) {
      if (option && option.code_region) {
        let region = option.code_region;
        if (!deployedRegion.includes(region)) {
          const notInDeployedRegion = document.querySelector("[data-error='not-in-deployed-region']")
          notInDeployedRegion.style.display = 'block'
          const newsletter = document.querySelector("[data-error='newsletter']")
          newsletter.style.display = 'block'
          fill_newsletter_form(region)
        }
      }
    }

    function displayErrorBlock() {
      indifusibleSiretHelp.style.display = "block";
    }

    function hideErrorBlock() {
      indifusibleSiretHelp.style.display = "none";
    }

    function reinitFormFields(query) {
      // fill hidden field in case autocomplete gives no result
      siretField.value = query;
      codeRegionField.value = "";
    }
  }

  function fill_newsletter_form (region_code) {
    const newsletter_region_field = document.getElementById("region_code")
    const solicitation_form_email = document.getElementById("solicitation_email")
    const newsletter_form_email = document.getElementById("email")
    newsletter_form_email.value = solicitation_form_email.value
    newsletter_region_field.value = region_code
  }

  // Récupération des résultats ----------------------------------------------------

  async function fetchEtablissements(query) {
    let params = `query=${query}&non_diffusables=false`; // pour ne pas afficher publiquement les SIRET non diffusibles
    let response = await fetch(`/rech-etablissement?${params}`, {
      credentials: "same-origin",
    });
    let data = await response.json();
    return data;
  }

  function filterResults(data) {
    return data.filter((etablissement) => {
      // remove Administrations from suggestions
      return etablissement.activite != "Administration publique générale";
    });
  }

  // Traitement des résultats --------------------------------------------
  function suggestionTemplate (result) {
    if (!result) return
    return (
      result &&
      `<strong> ${result.siret} (${result.nom}) </strong>
        <p><span class="small">${result.activite || ''} - ${result.lieu || ''}</span> </p>`
    );
  }

  function inputValueTemplate (result) {
    return result && `${result.siret} - ${result.nom}`;
  }

})()
