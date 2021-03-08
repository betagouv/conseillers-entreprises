import { exists, debounce } from '../shared/utils.js'
import accessibleAutocomplete from 'accessible-autocomplete';

(function () {
  addEventListener('turbo:load', setupCityAutocomplete)

  const SEARCH_URL = 'https://api-adresse.data.gouv.fr/search/?type=municipality&q='

  function setupCityAutocomplete () {
    const targetField = document.querySelector("[data-target='insee-code']")
    const autocompleteField = document.querySelector("[data-action='city-autocomplete']")
    if (exists(autocompleteField)) {
      accessibleAutocomplete({
        element: autocompleteField,
        id: 'city_autocomplete',
        showNoOptionsFound: false,
        templates: {
          inputValue: inputValueTemplate,
          suggestion: suggestionTemplate
        },
        tAssistiveHint: () => autocompleteField.dataset.assistiveHint,
        source: debounce(async (query, populateResults) => {
          // display autocomplete suggestions
          const res = await fetchSource(query, SEARCH_URL)
          const results = res.features
          populateResults(results)
        }, 300),
        onConfirm: (val) => {
          if (val) {
            targetField.value = val.properties.citycode
          }
        }
      })
    }
  }

  // Récupération des résultats ----------------------------------------------------

  async function fetchSource (query, url) {
    query = query.trim().toLowerCase().replace(/[^a-zA-Z0-9 -]/, "").replace(/\s/g, "-");
    const res = await fetch(
      `${url}${encodeURIComponent(query)}`
    )
    const data = await res.json()
    return data
  }

  // Traitement des résultats --------------------------------------------

  function suggestionTemplate (result) {
    if (!result) return
    const properties = result.properties
    return result && `<span></span><strong> ${properties.city} </strong> - ${properties.postcode}</p>`
  }

  function inputValueTemplate (result) {
    if (!result) return
    return `${result.properties.city} - ${result.properties.postcode}`
  }
})()

