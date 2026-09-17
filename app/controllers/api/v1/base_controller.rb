class Api::V1::BaseController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionDispatch::Http::Parameters::ParseError, with: :parsing_error
  serialization_scope :current_institution

  before_action :set_call_id
  before_action :authenticate_with_api_key!
  around_action :set_appsignal_context

  private

  # Identifiant de corrélation partagé avec les appelants, pour recouper les logs des deux côtés
  # lors d'une investigation. Posé avant l'authentification, pour couvrir aussi les réponses en erreur.
  def set_call_id
    response.set_header('X-Call-Id', request.request_id)
  end

  def authenticate_with_api_key!
    @current_institution = authenticate_or_request_with_http_token do |token, options|
      @current_api_key = ApiKey.authenticate_by_token! token
      @current_api_key&.institution
    end
  end

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
    ], status: :bad_request)
  end

  def current_institution
    @current_institution
  end

  def current_api_key
    @current_api_key
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
