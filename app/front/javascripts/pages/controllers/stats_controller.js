import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ['institution', 'antennes', 'subjects']

  async institutionFilters() {
    await fetch(`/stats/equipe/institution_filters?institution_id=${this.institutionTarget.value}`)
      .then((response) => response.json())
      .then((data) => this.updateFilters(data));
  }

  updateFilters(data) {
    this.updateAntennesOptions(data.antennes);
    this.updateSubjectsOptions(data.subjects);
  }

  updateAntennesOptions(antennes) {
    this.antennesTarget.innerHTML = "";
    let option = document.createElement("option");
    option.value = '';
    option.innerHTML = 'Toutes';
    this.antennesTarget.appendChild(option);
    antennes.forEach((antenne) => {
      const option = document.createElement("option");
      option.value = antenne.id;
      option.innerHTML = antenne.name;
      this.antennesTarget.appendChild(option);
    });
  }

  updateSubjectsOptions(subjects) {
    this.subjectsTarget.innerHTML = "";
    let option = document.createElement("option");
    option.value = '';
    option.innerHTML = 'Tous';
    this.subjectsTarget.appendChild(option);
    subjects.forEach((subject) => {
      const option = document.createElement("option");
      option.value = subject.id;
      option.innerHTML = subject.label;
      this.subjectsTarget.appendChild(option);
    });
  }
}
