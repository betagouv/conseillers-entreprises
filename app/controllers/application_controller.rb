# frozen_string_literal: true

class ApplicationController < ActionController::Base
  NOT_FOUND_ERROR_CLASSES = [
    ActionController::RoutingError,
    ActionController::UrlGenerationError,
    ActiveRecord::RecordNotFound,
    ActionView::MissingTemplate
  ].freeze

  protect_from_forgery with: :exception

  before_action :authenticate_user!

  respond_to :html, :json, :js
  rescue_from Exception, with: :render_error

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

  private

  def render_error(exception)
    if NOT_FOUND_ERROR_CLASSES.include? exception.class
      respond_with_status(404)
    else
      respond_with_status(500)
    end
  end

  def respond_with_status(status)
    respond_with do |format|
      format.html { render "errors/#{status}" }
      format.json { render body: nil, status: status }
      format.js { render body: nil, status: status }
    end
  end
end
