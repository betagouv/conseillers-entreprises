module Api
  # Api Call abstract implementation, to be subclassed for specific models.
  #
  class Base
    attr_reader :query

    def initialize(query, options = {})
      @query = FormatSiret.clean_siret(query)
      raise ApiError, I18n.t('api_requests.invalid_siret_or_siren') unless valid_query?
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
      handle_error_silently(http_request)
    end

    def handle_error_silently(http_request)
      if http_request.has_tech_error? || http_request.has_server_error?
        notify_tech_error(http_request)
        return { api_result_key => { "error" => Request::DEFAULT_TECHNICAL_ERROR_MESSAGE } }
      end
      return { api_result_key => { "error" => http_request.error_message } }
    end

    def handle_error_loudly(http_request)
      if http_request.has_tech_error? || http_request.has_server_error?
        notify_tech_error(http_request)
        raise ApiError, Request::DEFAULT_TECHNICAL_ERROR_MESSAGE
      else
        raise ApiError, http_request.error_message
      end
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

    # clé permettant d'identifier les données agglomérées
    def api_result_key
      ""
    end

    def valid_query?
      FormatSiret.siren_is_valid(@query) || FormatSiret.siret_is_valid(@query)
    end
  end

  class Request
    DEFAULT_ERROR_MESSAGE = I18n.t('api_requests.generic_error')
    DEFAULT_TECHNICAL_ERROR_MESSAGE = I18n.t('api_requests.partner_error')

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

    def response_status
      @http_response.status
    end

    def has_tech_error?
      error_code.present? && [400, 401, 403].include?(error_code)
    end

    def has_server_error?
      error_code.nil? || (error_code.present? && [500, 501, 502, 503, 504].include?(error_code))
    end

    def error_code
      @http_response&.code
    end

    def error_message
      @error&.message || data_error_message || @http_response.status.reason || DEFAULT_ERROR_MESSAGE
    end

    def data_error_message
      @data['erreur']
    end

    private
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

  class ApiError < StandardError; end
  class UnavailableApiError < StandardError; end
end
