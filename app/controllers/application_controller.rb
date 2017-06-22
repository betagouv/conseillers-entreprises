# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def authenticate_admin!
    current_user.is_admin? || redirect_to(root_path, alert: t('admin_authentication_failure'))
  end

  def set_admin_timezone
    Time.zone = 'Paris'
  end

  # Devise parameter
  def after_sign_in_path_for(_resource)
    visits_path
  end
end
