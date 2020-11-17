import { exists, debounce } from "../shared/utils.js";
import accessibleAutocomplete from "accessible-autocomplete";

(function () {
  addEventListener("DOMContentLoaded", setupSiretAutocomplete);

  const NAME_SEARCH_URL = "https://entreprise.data.gouv.fr/api/sirene/v1/full_text/";
  const SIRET_SEARCH_URL = "https://entreprise.data.gouv.fr/api/sirene/v3/unites_legales/";

  function setupSiretAutocomplete() {
    const targetField = document.querySelector("[data-target='siret-autocomplete']");
    const autocompleteField = document.querySelector("[data-action='siret-autocomplete']");

    if (exists(autocompleteField)) {
      accessibleAutocomplete({
        element: autocompleteField,
        id: "solicitation_siret_autocomplete",
        showNoOptionsFound: false,
        templates: {
          inputValue: inputValueTemplate,
          suggestion: suggestionTemplate,
        },
        tAssistiveHint: () => autocompleteField.dataset["assistiveHint"],
        source: debounce(async (query, populateResults) => {
          // fill hidden field in case autocomplete gives no result
          targetField.value = query;
          // display autocomplete suggestions
          let url = getSearchUrl(query);
          const res = await fetchSource(query, url);
          const filteredResults = filterResults(res);
          if (filteredResults) {
            populateResults(filteredResults);
          }
        }, 300),
        onConfirm: (option) => {
          fillSiretField(option);
        },
      });
    }

    function fillSiretField(option) {
      if (option && option["label"]) {
        let match = option["label"].match(/\d{14}/)[0];
        if (match) {
          targetField.value = match;
        }
      }
    }
  }

  // Récupération des résultats ----------------------------------------------------

  function getSearchUrl(query) {
    return isSiretSearch(query) ? SIRET_SEARCH_URL : NAME_SEARCH_URL;
  }

  async function fetchSource(query, url) {
    if (isSiretSearch(query)) query = query.replace(/\s/g, "");
    const res = await fetch(
      `${url}${encodeURIComponent(query)}?per_page=15`
    );
    const data = await res.json();
    return data;
  }

  // Traitement des résultats --------------------------------------------

  function filterResults(results) {
    if (results["message"] == "no results found") return;
    // Recherche par SIRET
    if (results["unite_legale"]) {
      let uniteLegale = results["unite_legale"]
      etablissement = uniteLegale["etablissement_siege"];
      return [{
        label: `${etablissement["siret"]} (${uniteLegale["denomination"]})`,
        address: etablissement["geo_adresse"]
      }];
    }
    // Recherche par nom
    if (results["etablissement"]) {
      return results["etablissement"]
        .filter((etablissement) => {
          // remove Administrations from suggestions
          return (etablissement["libelle_activite_principale"] != "Administration publique générale");
        })
        .map((etablissement) => {
          let name = getName(etablissement) .replace(/\*/g, " ");
          return {
            label: `${name} (${etablissement["siret"]})`,
            address: etablissement["geo_adresse"],
            activity: etablissement["libelle_activite_principale"],
          };
        });
    }
  }

  function suggestionTemplate (result) {
    if (!result) return
    let activity = result.activity ? `${result.activity} - ` : ''
    return result && `<strong> ${result.label} </strong>
        <p><span class="small">${activity}${result.address}</span> </p>`
  }

  function inputValueTemplate(result) {
    return result && result.label;
  }

  function getName(etablissement) {
    if (etablissement["nom"])
      return `${etablissement["nom"]} ${etablissement["prenom"]}`;
    if (etablissement["enseigne"]) return etablissement["enseigne"];
    return etablissement["nom_raison_sociale"];
  }

  // Utilities ----------------------------------------------------------------

  function isSiretSearch(str) {
    return str.replace(/\s/g, "").match(/^\d+$/g);
  }

})();
