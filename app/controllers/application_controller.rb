class ApplicationController < SharedController
  # Abstract Controller for the public pages
  # implicitly uses the 'application' layout

  include Pundit

  before_action :authenticate_user!

  def authenticate_admin!
    current_user.is_admin? || not_found
  end

  ## Devise overrides
  # See also RegistrationsController::after_sign_up_path_for
  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || diagnoses_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def current_expert
    Expert.find_by(access_token: params[:access_token])
  end

  def current_roles
    current_roles = [current_user]
    current_roles += current_user&.experts || []
    current_roles += [current_expert]
    current_roles.compact
  end

  def authenticate_expert!
    current_expert.present? || not_found
  end

  def check_current_user_access_to(resource)
    http_method = request.request_method
    access_method = if %w[GET HEAD].include?(http_method)
      :can_be_viewed_by?
    elsif %w[PATCH POST PUT DELETE].include?(http_method)
      :can_be_modified_by?
    end

    if resource.send(access_method, current_user)
      return
    end
    # can not be viewed:
    not_found
  end
end
