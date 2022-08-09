class Api::V1::BaseController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_with_api_key!

  private

  def authenticate_with_api_key!
    @current_institution = authenticate_or_request_with_http_token do |token, options|
      current_api_key = ApiKey.authenticate_by_token token
      current_api_key&.institution
    end
  end



  # rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # private def authenticate_api_token!
  #   authenticate_token || render_unauthorized
  # end
  #

  private

  # def authenticate_token
  #   authenticate_or_request_with_http_token do |token, options|
  #     @current_institution = institution.find_by(api_key: token)
  #   end
  # end

  # def render_unauthorized
  #   headers['WWW-Authenticate'] = 'Token realm=Application'
  #   render_error_payload(errors: "Authentification échouée", status: :unauthorized)
  # end

  # def render_serialized_payload(status: :ok)
  #   render json: yield, status: status
  # rescue ArgumentError => exception
  #   render_error_payload(errors: exception.message, status: 400)
  # end

  # def render_error_payload(errors: nil, status: :unprocessable_entity)
  #   if errors.is_a?(Struct)
  #     render json: { errors: errors.to_h }, status: status
  #   elsif errors.is_a?(Hash)
  #     render json: { errors: errors }, status: status
  #   elsif errors.is_a?(String)
  #     render json: { errors: errors }, status: status
  #   end
  # end

  # def record_not_found
  #   render_error_payload(errors: 'Record not found', status: 404)
  # end

  def current_institution
    @current_institution
  end

end