import { stimulus_app } from "../../shared/stimulus_app"

import AutocompleteController from "./autocomplete_controller"
stimulus_app.register("autocomplete", AutocompleteController)
import BadgesController from "./badges_controller"
stimulus_app.register("badges", BadgesController)
import CguAcceptanceController from "./cgu_acceptance_controller"
stimulus_app.register("cgu-acceptance", CguAcceptanceController)
import CoverageController from "./coverage_controller"
stimulus_app.register("coverage", CoverageController)
import DiagnosisNeedsStepController from "./diagnosis_needs_step_controller"
stimulus_app.register("diagnosis-needs-step", DiagnosisNeedsStepController)
import ExpertAutocompleteController from "./expert_autocomplete_controller"
stimulus_app.register("expert-autocomplete", ExpertAutocompleteController)
import FeedbackFormController from "./feedback_form_controller"
stimulus_app.register("feedback-form", FeedbackFormController)
import FrHeaderController from "./fr_header_controller"
stimulus_app.register("fr-header", FrHeaderController)
import PasswordVisibilityController from "./password_visibility_controller"
stimulus_app.register("password-visibility", PasswordVisibilityController)
import ToggleBlockController from "./toggle_block_controller"
stimulus_app.register("toggle-block", ToggleBlockController)
import UserAppInfoController from "./user_app_info_controller"
stimulus_app.register("user-app-info", UserAppInfoController)
