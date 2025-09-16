module Api
  # Api Call abstract implementation, to be subclassed for specific models.
  #
  class Base
    attr_reader :query

    def initialize(query, options = {})
      # wait on parle forcément de siret/siren dans toutes ces apis?
      # Non, lol, certaines sous-classes n’appellent pas surper dans leur initialize.
      @query = FormatSiret.clean_siret(query)
      raise Api::BasicError, I18n.t('api_requests.invalid_siret_or_siren') unless valid_query?
      @options = options
    end

    def call
      result = simulate_error
      return result if result
      # we need to simulate errors:
      # - per api?
      # - specify type (raise basic / raise technical / return unreachable / return standard )
      Rails.cache.fetch([id_key, @query].join('-'), expires_in: 12.hours) do
        http_request = request
        if http_request.success?
          responder(http_request).call
        else
          handle_error(http_request)
        end
      end
    end

    def simulate_error
      return unless Rails.env.development?

      message = ENV['DEVELOPMENT_ENABLE_API_ERRORS_SIMULATION']
      return if message.blank?

      simulation = {
        "api-apientreprise-etablissementeffectifmensuel-base" => -> { raise TechnicalError.new(api: id_key), "Ceci est un message d’erreur simulé." },
        "api-francecompetence-siret-base" => -> { return {errors: { unreachable_apis: {id_key => "Ceci aussi est un message d’erreur simulé."} }}}
      }[id_key]

      return simulation.call if simulation
    end

    def request
      self.class.module_parent::Request.new(@query, @options)
    end

    def responder(http_request)
      self.class.module_parent::Responder.new(http_request)
    end

    def handle_error(http_request)
      # On raise les erreurs api qu'on souhaite "bloquantes" (=pas de process si l'API est en carafe)
      if (severity == :major)
        raise TechnicalError.new(api: id_key), http_request.error_message # maybe don’t? Save the error and let the calling process handle it?
      else
        # on enregistre les autres erreurs pour pouvoir les traiter + tard
        error_type = http_request.has_unreachable_api_error? ? :unreachable_apis : :standard_api_errors # and have a new error type here for technical errors?
        return {
          errors: { error_type => { id_key => http_request.error_message } }
        }
      end
    end

    def severity
      :minor
    end

    def id_key
      self.class.name.parameterize
    end

    def valid_query?
      FormatSiret.siren_is_valid(@query) || FormatSiret.siret_is_valid(@query)
    end
  end

  class Request
    DEFAULT_ERROR_MESSAGE = I18n.t('api_requests.generic_error')
    DEFAULT_TECHNICAL_ERROR_MESSAGE = I18n.t('api_requests.partner_error')
    CLIENT_HTTP_ERRORS = [400, 401, 403]
    SERVER_ERRORS = [ 500, 501, 502, 503, 504]

    attr_reader :data

    def initialize(query, options = {})
      @query = query
      @options = options
      begin
        @http_response = get_url
        @data = @http_response.parse(:json)
      rescue StandardError => e
        @error = e
      end
    end

    def get_url
      HTTP.get(url)
    end

    def success?
      @error.nil? && response_status.success?
    end

    def has_unreachable_api_error?
      error_code.nil? || (self.class::CLIENT_HTTP_ERRORS + self.class::SERVER_ERRORS).include?(error_code)
    end

    def error_code
      @http_response&.code
    end

    def error_message
      @error&.message || data_error_message || response_status.reason || DEFAULT_ERROR_MESSAGE
    end

    private

    def response_status
      @http_response.status
    end

    def data_error_message
      @data['erreur']
    end
  end

  class Responder
    def initialize(http_request)
      @http_request = http_request
    end

    def call
      format_data
    end

    def format_data
      @http_request.data
    end
  end

  class BasicError < StandardError; end

  class TechnicalError < StandardError
    attr_reader :api

    def initialize(api:)
      super
      @api = api
    end
  end
end
