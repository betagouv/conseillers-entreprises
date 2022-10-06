module ApiInsee
  class Base
    attr_reader :siren_or_siret

    def initialize(siren_or_siret, options = {})
      @siren_or_siret = FormatSiret.clean_siret(siren_or_siret)
      raise ApiInseeError, I18n.t('api_requests.invalid_siret_or_siren') unless valid_siren_or_siret?
      @options = options
    end

    def call
      Rails.cache.fetch([id_key, @siren_or_siret].join('-'), expires_in: 12.hours) do
        http_request = request
        if http_request.success?
          responder(http_request).call
        elsif http_request.unavailable_api?
          raise UnavailableApiError, I18n.t('api_requests.generic_error')
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
      raise ApiInseeError, I18n.t('api_requests.generic_error')
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

    attr_reader :data

    def initialize(siren_or_siret, options = {})
      @siren_or_siret = siren_or_siret
      @options = options
      @http_response = HTTP.auth("Bearer #{token}").get(url)
      begin
        @data = @http_response.parse(:json)
      rescue StandardError => e
        @error = e
      end
    end

    def token
      @token ||= ApiInsee::Token::Base.new.call
    end

    def success?
      @error.nil? && response_status.success?
    end

    def unavailable_api?
      response_status.internal_server_error? || response_status.bad_gateway? || response_status.service_unavailable?
    end

    def response_status
      @http_response.status
    end

    def error_message
      @error&.message || @data['errors']&.join('\n') || @http_response.status.reason || DEFAULT_ERROR_MESSAGE
    end

    private

    def base_url
      @base_url ||= "https://api.insee.fr/entreprises/sirene/V3/"
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

    def check_if_foreign_facility(etablissement)
      foreign_country = etablissement['adresseEtablissement']["libellePaysEtrangerEtablissement"]
      raise ApiInseeError, I18n.t('api_requests.foreign_facility', country: foreign_country.capitalize) if foreign_country.present?
    end
  end

  class ApiInseeError < StandardError; end
  class UnavailableApiError < StandardError; end
end
