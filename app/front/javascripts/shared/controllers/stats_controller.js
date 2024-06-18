import { exists } from '../utils.js';

import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ['institution', 'antennes', 'themes', 'subjects', 'loader', 'url']
  
  BLOCKS = {
    0: 'intern',
    1: 'iframe',
    2: 'api'
  }
  
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

  toggleIntegrationSelect(data) {
    let selectedIntegration = this.BLOCKS[data.target.value];
    this.element.querySelectorAll(`[data-integration]`).forEach((integrationSelect) => {
      integrationSelect.value = '';
      integrationSelect.setAttribute("disabled", true);
      integrationSelect.parentElement.style.display = 'none';
    })
    let chosenSelect = this.element.querySelector(`[data-integration='${selectedIntegration}']`)
    if (exists(chosenSelect)) {
      chosenSelect.parentElement.style.display = 'block'
      chosenSelect.removeAttribute("disabled");
    }
  }
}
