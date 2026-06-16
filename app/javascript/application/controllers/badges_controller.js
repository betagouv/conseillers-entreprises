import { Controller } from "stimulus";
import SlimSelect from 'slim-select';

export default class extends Controller {
  static targets = [ 'form', 'list', 'select' ]

  connect() {
    new SlimSelect({
      select: "#" + this.selectTarget.id,
      settings: {
        searchPlaceholder: 'Rechercher',
        searchText: 'Pas de résultat',
        searchingText: 'Recherche...',
        placeholderText: 'Sélectionnez des badges',
      }
    })
  }
  toggleForm() {
    this.formTarget.classList.toggle("hide")
    this.listTarget.classList.toggle("hide")
  }
}
