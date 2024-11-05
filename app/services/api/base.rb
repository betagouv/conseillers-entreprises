module Api
  # Api Call abstract implementation, to be subclassed for specific models.
  #
  class Base
    attr_reader :query

    def initialize(query, options = {})
      @query = FormatSiret.clean_siret(query)
      raise Api::BasicError, I18n.t('api_requests.invalid_siret_or_siren') unless valid_query?
      @options = options
    end

    def call
      Rails.cache.fetch([id_key, @query].join('-'), expires_in: 12.hours) do
        http_request = request
        if http_request.success?
          responder(http_request).call
        else
          handle_error(http_request)
        end
      end
    end

    def request
      request_class_name = [self.class.name.deconstantize, 'Request'].join('::')
      request_class_name.constantize.new(@query, @options)
    end

    def responder(http_request)
      responder_class_name = [self.class.name.deconstantize, 'Responder'].join('::')
      responder_class_name.constantize.new(http_request)
    end

    def handle_error(http_request)
      notify_tech_error(http_request) if http_request.has_unreachable_api_error?
      raise TechnicalError.new(api: id_key, severity: severity), http_request.error_message if (severity == :major)

      error_type = http_request.has_unreachable_api_error? ? :unreachable_apis : :basic_errors
      return {
        errors: { error_type => { id_key => http_request.error_message } }
      }
    end

    def severity
      :minor
    end

    def notify_tech_error(http_request)
      tags = {
        error_message: http_request.error_message.gsub(/[\n\r]/, " ").strip
      }
      tags.merge({ error_code: http_request.error_code }) if http_request.error_code.present?
      Sentry.with_scope do |scope|
        scope.set_tags(tags)
        Sentry.capture_message("Erreur #{self.class.name}")
      end
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
        pp @data
      rescue StandardError => e
        pp e
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

    def response_status
      @http_response.status
    end

    def error_code
      @http_response&.code
    end

    def error_message
      @error&.message || data_error_message || response_status.reason || DEFAULT_ERROR_MESSAGE
    end

    def data_error_message
      @data['erreur']
    end

    # clé permettant d'identifier les données agglomérées
    def api_result_key
      ""
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
      pp @http_request.data
      @http_request.data
    end
  end

  class BasicError < StandardError; end

  class TechnicalError < StandardError
    attr_reader :api, :severity

    def initialize(api:, severity: :minor)
      super
      @api = api
      @severity = severity
    end
  end
end
