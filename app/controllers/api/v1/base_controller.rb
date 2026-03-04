class Api::V1::BaseController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  serialization_scope :current_institution

  before_action :authenticate_with_api_key!
  around_action :set_appsignal_context

  private

  def authenticate_with_api_key!
    @current_institution = authenticate_or_request_with_http_token do |token, options|
      current_api_key = ApiKey.authenticate_by_token! token
      current_api_key&.institution
    end
  end

  private

  def render_error_payload(errors: nil, status: :unprocessable_content)
    render json: { errors: errors }, status: status
  end

  def record_not_found(e)
    source = e.model.constantize.model_name.human
    errors = [
      {
        source: source,
        message: I18n.t('api_pde.errors.not_found')
      }
    ]
    render_error_payload(errors: errors, status: 404)
  end

  def parsing_error(e)
    render_error_payload(errors: [
      { source: I18n.t('api_pde.errors.parsing.source'), message: I18n.t('api_pde.errors.parsing.message') }
    ])
  end

  def current_institution
    @current_institution
  end

  def sanitize_params(params)
    params.each do |key, value|
      next if value.class != String
      params[key] = ActionController::Base.helpers.sanitize(value, tags: %w[a p img], attributes: %w[alt])
    end
    params
  end

  def set_appsignal_context
    Appsignal.set_namespace("api")
    Appsignal.set_tags(
      api_version: "v1",
      institution_id: current_institution&.id,
      institution_name: current_institution&.name
    )
    yield
  end
end
