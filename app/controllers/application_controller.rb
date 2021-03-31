class ApplicationController < SharedController
  # Abstract Controller for the App pages
  # implicitly uses the 'application' layout

  include Pundit

  before_action :authenticate_user!

  def authenticate_admin!
    current_user.is_admin? || not_found
  end

  ## Devise overrides
  # See also RegistrationsController::after_sign_up_path_for
  def after_sign_in_path_for(resource_or_scope)
    if resource_or_scope.relevant_experts.with_subjects.present?
      path = needs_path
    elsif resource_or_scope.can_view_diagnoses_tab
      path = diagnoses_path
    else
      path = quo_needs_path
    end
    stored_location_for(resource_or_scope) || path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
