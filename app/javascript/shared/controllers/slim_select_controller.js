import { Controller } from "stimulus";
import SlimSelect from 'slim-select';

export default class extends Controller {
  connect() {
    this.placeholderTextValue ||= 'Sélectionner'

    new SlimSelect({
      select: this.element,
      settings: {
        searchPlaceholder: 'Rechercher',
        searchText: 'Pas de résultat',
        searchingText: 'Recherche…',
        placeholderText: 'Sélectionner',
      }
    })
  }
}
