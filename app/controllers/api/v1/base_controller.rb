class Api::V1::BaseController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  before_action :authenticate_with_api_key!

  private

  def authenticate_with_api_key!
    @current_institution = authenticate_or_request_with_http_token do |token, options|
      current_api_key = ApiKey.authenticate_by_token! token
      current_api_key&.institution
    end
  end

  private

  def render_serialized_payload(status: :ok)
    render json: yield, status: status
  end

  def render_error_payload(errors: nil, status: :unprocessable_entity)
    render json: { errors: errors }, status: status
  end

  def record_not_found
    render_error_payload(errors: I18n.t('shared.errors.api.404.message'), status: 404)
  end

  def current_institution
    @current_institution
  end
end
