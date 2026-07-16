import { stimulus_app } from "../../shared/stimulus_app"

import SiretAutocompleteController from "./siret_autocomplete_controller"
stimulus_app.register("siret-autocomplete", SiretAutocompleteController)
import PrefillTextareaController from "./prefill_textarea_controller"
stimulus_app.register("prefill-textarea", PrefillTextareaController)
