import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ['institution', 'antennes']

  async searchAntennes() {
    await fetch(`/stats/equipe/search_antennes?institution_id=${this.institution}`)
      .then((response) => response.json())
      .then((data) =>
        this.updateAntennesOptions(data));
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

  get institution() {
    return this.institutionTarget.value
  }
}
