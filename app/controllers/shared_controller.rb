# frozen_string_literal: true

class SharedController < ActionController::Base
  NOT_FOUND_ERROR_CLASSES = [
    ActionController::RoutingError,
    ActionController::UrlGenerationError,
    ActiveRecord::RecordNotFound,
    ActionView::MissingTemplate,
    Pundit::NotAuthorizedError
  ].freeze

  protect_from_forgery with: :exception

  before_action :set_raven_context

  respond_to :html, :js
  rescue_from Exception, with: :render_error

  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end

  private

  def render_error(exception)
    raise exception if Rails.env.development? || (Rails.env.test? && !ENV['TEST_ERROR_RENDERING'].to_b)
    if NOT_FOUND_ERROR_CLASSES.include? exception.class
      respond_with_status(404)
    else
      Raven.capture_exception(exception)
      respond_with_status(500)
    end
  end

  def set_raven_context
    Raven.user_context(
      username: current_user&.full_name,
      email: current_user&.email,
      id: current_user&.id,
      ip_address: request.ip
    )
    Raven.extra_context(
      params: params.to_unsafe_h,
      url: request.url
    )
  end

  def respond_with_status(status)
    respond_with do |format|
      format.html { render "shared/errors/#{status}" }
      format.js { render body: nil, status: status }
    end
  end
end
