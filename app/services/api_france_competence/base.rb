module ApiFranceCompetence
  class Base
    attr_reader :siren_or_siret

    def initialize(siren_or_siret, options = {})
      @siren_or_siret = FormatSiret.clean_siret(siren_or_siret)
      raise ApiFranceCompetenceError, I18n.t('api_requests.invalid_siret_or_siren') unless valid_siren_or_siret?
      @options = options
    end

    def call
      Rails.cache.fetch([id_key, @siren_or_siret].join('-'), expires_in: 12.hours) do
        http_request = request
        if http_request.success?
          responder(http_request).call
        else
          handle_error(http_request)
        end
      end
    end

    def request
      Request.new(@siren_or_siret, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end

    def handle_error(http_request)
      return { "opco_fc" => { "error" => http_request.error_message } }
    end

    def id_key
      self.class.name.parameterize
    end

    def valid_siren_or_siret?
      FormatSiret.siren_is_valid(@siren_or_siret) || FormatSiret.siret_is_valid(@siren_or_siret)
    end
  end

  class Request
    DEFAULT_ERROR_MESSAGE = I18n.t('api_requests.generic_error')
    ERROR_CODES = {}

    attr_reader :data

    def initialize(siren_or_siret, options = {})
      @siren_or_siret = siren_or_siret
      @options = options
      @http_response = HTTP.auth("Bearer #{token}").get(url, headers: headers)
      begin
        @data = @http_response.parse(:json)
      rescue StandardError => e
        @error = e
      end
    end

    def token
      @token ||= ApiFranceCompetence::Token::Base.new.call
    end

    def headers
      @headers ||= {
        'X-Gravitee-Api-Key' => ENV.fetch('FRANCE_COMPETENCE_SIRO_KEY')
      }
    end

    def success?
      @error.nil? && response_status.success? && !ERROR_CODES.key?(data['code'])
    end

    def response_status
      @http_response.status
    end

    def error_message
      @error&.message || @data['errors']&.join('\n') || @http_response.status.reason || DEFAULT_ERROR_MESSAGE
    end

    private

    def base_url
      @base_url ||= "https://api-preprod.francecompetences.fr/"
    end

    def url_key
      @url_key ||= ""
    end

    def url
      @url ||= "#{base_url}#{url_key}#{@siren_or_siret}"
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

  class ApiFranceCompetenceError < StandardError; end
end
