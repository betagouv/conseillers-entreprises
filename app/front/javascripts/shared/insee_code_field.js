import { exists, debounce } from './utils.js'
import accessibleAutocomplete from 'accessible-autocomplete';

(function () {
  addEventListener('turbo:load', setupCityAutocomplete)

  const SEARCH_URL = '/communes/search?q='

  function setupCityAutocomplete () {
    const targetField = document.querySelector("[data-target='insee-code']")
    const autocompleteField = document.querySelector("[data-action='city-autocomplete']")

    if (exists(autocompleteField) && exists(targetField)) {
      accessibleAutocomplete({
        element: autocompleteField,
        id: autocompleteField.dataset.id || 'city_autocomplete',
        name: autocompleteField.dataset.name || 'query',
        showNoOptionsFound: false,
        minLength: 3,
        templates: {
          inputValue: inputValueTemplate,
          suggestion: suggestionTemplate
        },
        tAssistiveHint: () => autocompleteField.dataset.assistiveHint,
        source: debounce(async (query, populateResults) => {
          // display autocomplete suggestions
          const results = await fetchSource(query, SEARCH_URL).catch(displayError)
          populateResults(results || [])
        }, 150),
        onConfirm: (val) => {
          if (val && targetField) {
            // data-value-type="insee-code" → store INSEE code only (e.g., "75056")
            // data-value-type="formatted" → store formatted "City (DEPT)" string (e.g., "Paris (75)")
            const valueType = targetField.dataset.valueType || 'insee-code'

            if (valueType === 'insee-code') {
              targetField.value = val.code
            } else {
              targetField.value = `${val.nom} (${val.departement_code})`
            }
          }
        }
      })

      const defaultValue = autocompleteField.dataset.defaultValue
      if (exists(defaultValue)) {
        document.querySelector('#city_autocomplete').value = defaultValue
      }
    }
  }

  // Récupération des résultats ----------------------------------------------------

  async function fetchSource (query, url) {
    query = query.trim();
    const res = await fetch(`${url}${encodeURIComponent(query)}`)
    if (res.ok) {
      return await res.json()
    } else {
      return Promise.reject(res);
    }
  }

  // Traitement des résultats --------------------------------------------

  function suggestionTemplate (result) {
    if (!result) return
    return result && `<span></span><strong> ${result.nom} </strong> (${result.departement_code})</p>`
  }

  function inputValueTemplate (result) {
    if (!result) return
    return `${result.nom} (${result.departement_code})`
  }

  function displayError (err) {
    console.warn(err);
    alert(`Désolée, un problème a été rencontré, vous pouvez réessayer un peu + tard` );
  }
})()
