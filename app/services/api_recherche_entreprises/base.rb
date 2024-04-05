module ApiRechercheEntreprises
  class Base
    attr_reader :query

    def initialize(query, options = {})
      @query = encode_query(query)
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
      Request.new(@query, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end

    def handle_error(http_request)
      Sentry.with_scope do |scope|
        scope.set_tags({ 
        error_code: http_request.error_code,
        error_message: http_request.error_message
      })
        Sentry.capture_message("Erreur Api Recherche Entreprise")
      end
      raise ApiError, http_request.error_message
    end

    def id_key
      self.class.name.parameterize
    end

    def encode_query(query)
      query = I18n.transliterate(query, locale: :fr)
        .strip
        .squeeze(' ')
      ERB::Util.url_encode(query)
    end
  end

  class Request
    DEFAULT_ERROR_MESSAGE = I18n.t('api_requests.generic_error')

    attr_reader :data

    def initialize(query, options = {})
      @query = query
      @options = options
      @http_response = HTTP.get(url)
      begin
        @data = @http_response.parse(:json)
      rescue StandardError => e
        @error = e
      end
    end

    def success?
      @error.nil? && @http_response.status.success?
    end

    def error_message
      @error&.message || @data['erreur'] || @http_response.status.reason || DEFAULT_ERROR_MESSAGE
    end

    def error_code
      @http_response.code
    end

    private

    def base_url
      @base_url ||= "https://recherche-entreprises.api.gouv.fr/"
    end

    def url_key
      @url_key ||= ""
    end

    def url
      @url ||= "#{base_url}#{url_key}#{@query}"
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

  class ApiError < StandardError; end
end
