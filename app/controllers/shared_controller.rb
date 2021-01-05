# frozen_string_literal: true

class SharedController < ActionController::Base
  NOT_FOUND_ERROR_CLASSES = [
    ActionController::RoutingError,
    ActionController::UrlGenerationError,
    ActionController::UnknownFormat,
    ActiveRecord::RecordNotFound,
    ActionView::MissingTemplate,
    Pundit::NotAuthorizedError
  ].freeze

  protect_from_forgery with: :exception

  before_action :set_raven_context

  rescue_from Exception, with: :render_error

  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end

  include IframePrefix::InIframe # Note: This could be included in PagesController, there's currently no need for in the ApplicationController.

  private

  def render_error(exception)
    raise exception if (Rails.env.development? || Rails.env.test?) && !ENV['TEST_ERROR_RENDERING'].to_b
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
    respond_to do |format|
      format.html { render "shared/errors/#{status}", status: status }
      format.any { head status }
    end
  end
end
