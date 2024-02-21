import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ['institution', 'antennes', 'themes', 'subjects', 'iframes', 'loader', 'url']

  initialize() {
    this.url = this.element.dataset.url
  }

  async fetchFilters() {
    for(let loader of this.loaderTargets) { loader.style.display = 'inline-block'}
    let institutionParams = this.hasInstitutionTarget ? `institution=${this.institutionTarget.value}` : null;
    let themesParams = this.hasThemesTarget ? `theme=${this.themesTarget.value}` : null;
    let params = [institutionParams, themesParams].filter(n => n).join('&')

    await fetch(`${this.url}?${params}`)
      .then((response) => response.json())
      .then((data) => this.updateFilters(data));
  }

  updateFilters(data) {
    if (this.hasAntennesTarget && data.antennes ) this.updateAntennesOptions(data.antennes);
    if (this.hasThemesTarget && data.themes ) this.updateThemesOptions(data.themes);
    this.updateSubjectsOptions(data.subjects);
    for(let loader of this.loaderTargets) { loader.style.display = 'none'}
  }

  updateAntennesOptions(antennes) {
    this.updateOptions(antennes, this.antennesTarget, "Toutes")
  }

  updateThemesOptions(themes) { 
    this.updateOptions(themes, this.themesTarget, "Toutes")
  }

  updateSubjectsOptions(subjects) {
    this.updateOptions(subjects, this.subjectsTarget, "Tous")
  }

  updateOptions(newOptions, target, emptyLabel) {
    let previouslySelectedValue = target.value
    target.innerHTML = "";
    let option = document.createElement("option");
    option.value = '';
    option.innerHTML = emptyLabel;
    target.appendChild(option);
    newOptions.forEach((newOption) => {
      const option = document.createElement("option");
      option.value = newOption.id;
      option.innerHTML = Object.prototype.hasOwnProperty.call(newOption, 'label') ? newOption.label : newOption.name;
      target.appendChild(option);
    });
    // on conserve l'ancienne value si présente dans les options
    if(newOptions.map(t => t.id).includes(Number(previouslySelectedValue))) {
      target.value = previouslySelectedValue
    }
  }

  toggleIframeSelect(data) {
    let selectedIntegration = data.target.value
    // On utilise 1 au lieu de 'iframe' car ça déclenche une erreur Postgres dans les filtres
    if (selectedIntegration == 1) {
      this.iframesTarget.parentElement.style.display = 'block'
    } else {
      this.iframesTarget.value = ''
      this.iframesTarget.parentElement.style.display = 'none'
    }
  }
}
