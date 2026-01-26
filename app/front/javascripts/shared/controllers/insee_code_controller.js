import { Controller } from "stimulus"
import accessibleAutocomplete from 'accessible-autocomplete'

function suggestionTemplate(result) {
  if (!result) return
  return `<span></span><strong> ${result.nom} </strong> (${result.departement_code})</p>`
}

function inputValueTemplate(result) {
  if (!result) return
  return `${result.nom} (${result.departement_code})`
}

export default class extends Controller {
  static targets = ["autocomplete", "hidden"]
  static values = { url: String, defaultValue: String, minLength: Number }

  initialize() {
    const autocompleteId = this.autocompleteTarget.dataset.id || 'city_autocomplete'
    this.searchUrl = this.hasUrlValue ? this.urlValue : '/api/internal/communes/search'
    const minLength = this.hasMinLengthValue ? this.minLengthValue : 3

    accessibleAutocomplete({
      element: this.autocompleteTarget,
      id: autocompleteId,
      name: this.autocompleteTarget.dataset.name || 'query',
      showNoOptionsFound: false,
      minLength: minLength,
      templates: {
        inputValue: inputValueTemplate,
        suggestion: suggestionTemplate
      },
      tAssistiveHint: () => this.autocompleteTarget.dataset.assistiveHint,
      source: this.debouncedSource.bind(this),
      onConfirm: this.onConfirm.bind(this)
    })
  }

  connect() {
    if (this.hasDefaultValueValue && this.defaultValueValue) {
      const autocompleteId = this.autocompleteTarget.dataset.id || 'city_autocomplete'
      const input = this.element.querySelector(`#${autocompleteId}`)
      if (input) {
        input.value = this.defaultValueValue
      }
    }
  }

  debouncedSource(query, populateResults) {
    clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(async () => {
      const results = await this.fetchSource(query).catch(this.displayError)
      populateResults(results || [])
    }, 150)
  }

  async fetchSource(query) {
    query = query.trim()
    const res = await fetch(`${this.searchUrl}?q=${encodeURIComponent(query)}`)
    if (res.ok) {
      return await res.json()
    } else {
      return Promise.reject(res)
    }
  }

  onConfirm(val) {
    if (val && this.hasHiddenTarget) {
      this.hiddenTarget.value = val.code
    }
  }

  displayError(err) {
    console.warn(err)
    alert("Désolé, un problème a été rencontré, vous pouvez réessayer un peu plus tard")
  }
}
