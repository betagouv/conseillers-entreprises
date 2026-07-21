import { Controller } from "stimulus";
import SlimSelect from 'slim-select';

export default class extends Controller {
  static values = {searchPlaceholder: String, searchText: String, searchingText: String, placeholderText: String}

  connect() {
    new SlimSelect({
      select: this.element,
      settings: {
        searchPlaceholder: this.searchPlaceholderValue,
        searchText: this.searchTextValue,
        searchingText: this.searchingTextValue,
        placeholderText: this.placeholderTextValue,
      }
    })
  }
}
