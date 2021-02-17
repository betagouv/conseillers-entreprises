import { exists, debounce } from '../shared/utils.js'
import accessibleAutocomplete from 'accessible-autocomplete';
import { departments_to_regions } from './departments_to_regions';

(function () {
  addEventListener('DOMContentLoaded', setupSiretAutocomplete)

  const NAME_SEARCH_URL = 'https://entreprise.data.gouv.fr/api/sirene/v1/full_text/'
  const SIRET_SEARCH_URL = 'https://entreprise.data.gouv.fr/api/sirene/v3/unites_legales/'

  function setupSiretAutocomplete () {
    const targetField = document.querySelector("[data-target='siret-autocomplete']")
    const autocompleteField = document.querySelector("[data-action='siret-autocomplete']")
    if (autocompleteField === null) return
    const deployedRegion = autocompleteField.getAttribute('data-deployed-regions')

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
          // fill hidden field in case autocomplete gives no result
          targetField.value = query
          // display autocomplete suggestions
          const url = getSearchUrl(query)
          const res = await fetchSource(query, url)
          const filteredResults = filterResults(res)
          if (filteredResults) {
            populateResults(filteredResults)
          }
        }, 300),
        onConfirm: (option) => {
          fillSiretField(option)
          CheckIfInDeployedRegion(option)
        }
      })
    }

    function fillSiretField (option) {
      if (option && option.label) {
        const match = option.label.match(/\d{14}/)[0]
        if (match) {
          targetField.value = match
        }
      }
    }

    function CheckIfInDeployedRegion (option) {
      if (typeof option == 'undefined') return
      let region = null
      if (typeof option.postal_code !== 'undefined') {
        const department = option.postal_code.slice(0, 2)
        region =fetchCodeRegion(department)
      }
      else if (typeof option.region !== 'undefined') {
        region = option.region
      }
      if (!deployedRegion.includes(region)) {
        const notInDeployedRegion = document.querySelector("[data-error='not-in-deployed-region']")
        notInDeployedRegion.style.display = 'block'
        const newsletter = document.querySelector("[data-error='newsletter']")
        newsletter.style.display = 'block'

        fill_newsletter_form(region)
      }
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

  function getSearchUrl (query) {
    return isSiretSearch(query) ? SIRET_SEARCH_URL : NAME_SEARCH_URL
  }

  async function fetchSource (query, url) {
    if (isSiretSearch(query)) query = query.replace(/\s/g, '')
    const res = await fetch(
      `${url}${encodeURIComponent(query)}?per_page=15`
    )
    const data = await res.json()
    return data
  }

  // Traitement des résultats --------------------------------------------

  function filterResults (results) {
    const indifusibleSiretHelp = document.querySelector("[data-error='indiffusible-siret']")

    if (results.message == 'no results found') return
    // Recherche par SIRET
    if (results.unite_legale) {
      indifusibleSiretHelp.style.display = "none";
      const uniteLegale = results.unite_legale
      const etablissement = uniteLegale.etablissement_siege
      // les siret indiffusiblse ne sortent aucun résultat
      if (!exists(etablissement)) {
        indifusibleSiretHelp.style.display = 'block'
        return
      }
      return [
        {
          label: `${etablissement.siret} (${uniteLegale.denomination})`,
          address: etablissement.geo_adresse,
          postal_code: etablissement.code_postal
        },
      ];
    }
    // Recherche par nom
    if (results.etablissement) {
      indifusibleSiretHelp.style.display = "none";
      return results.etablissement
        .filter((etablissement) => {
          // remove Administrations from suggestions
          return (etablissement.libelle_activite_principale != 'Administration publique générale')
        })
        .map((etablissement) => {
          const name = getName(etablissement).replace(/\*/g, ' ')
          return {
            label: `${name} (${etablissement.siret})`,
            address: etablissement.geo_adresse,
            activity: etablissement.libelle_activite_principale,
            region: etablissement.region
          }
        })
    }
  }

  function suggestionTemplate (result) {
    if (!result) return
    const activity = result.activity ? `${result.activity} - ` : ''
    return result && `<strong> ${result.label} </strong>
        <p><span class="small">${activity}${result.address}</span> </p>`
  }

  function inputValueTemplate (result) {
    return result && result.label
  }

  function getName (etablissement) {
    if (etablissement.nom) { return `${etablissement.nom} ${etablissement.prenom}` }
    if (etablissement.enseigne) return etablissement.enseigne
    return etablissement.nom_raison_sociale
  }

  // Utilities ----------------------------------------------------------------

  function isSiretSearch (str) {
    return str.replace(/\s/g, '').match(/^\d+$/g)
  }

  async function fetchCodeRegion(department) {
    let response = await fetch(`/code-region/${department}`)
    let data = await response.json()
    return data.code_region
  }
})()
