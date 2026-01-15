class ApplicationController < SharedController
  # Abstract Controller for the App pages
  # implicitly uses the 'application' layout

  before_action :authenticate_user!
  before_action :fetch_themes, if: :devise_controller?

  def authenticate_admin!
    current_user.is_admin? || not_found
  end

  def app_root_for_user(user = current_user)
    if user.sign_in_count == 1
      tutoriels_path
    elsif user.is_only_cooperation_manager?
      needs_conseiller_cooperations_path
    elsif user.is_manager?
      reports_path
    elsif user.is_admin?
      conseiller_solicitations_path
    else
      quo_active_needs_path
    end
  end
  helper_method :app_root_for_user

  ## Devise overrides
  def after_sign_in_path_for(user)
    stored_location_for(user) || app_root_for_user(user)
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
