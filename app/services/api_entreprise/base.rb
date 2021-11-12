module ApiEntreprise

  class Base
    attr_reader :siren_or_siret

    def initialize(siren_or_siret)
      @siren_or_siret = FormatSiret.clean_siret(siren_or_siret)
      raise ApiEntrepriseError, "L'identifiant (siret ou siren) est invalide" unless valid_siren_or_siret?
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
      Request.new(@siren_or_siret)
    end

    def responder(http_request)
      Responder.new(http_request)
    end

    def handle_error(http_request)
      raise ApiEntrepriseError, http_request.error_message
    end

    def id_key
      self.class.name.parameterize
    end

    def valid_siren_or_siret?
      FormatSiret.siren_is_valid(@siren_or_siret) || FormatSiret.siret_is_valid(@siren_or_siret)
    end
  end

  class Request
    DEFAULT_ERROR_MESSAGE = I18n.t('api_entreprise.default_error_message.etablissement')

    attr_reader :data

    def initialize(siren_or_siret)
      @siren_or_siret = siren_or_siret
      @http_response = HTTP.get(url)
      begin
        @data = @http_response.parse(:json)
      rescue StandardError => e
        p e
        @error = e
      end
    end

    def success?
      @error.nil? && @http_response.status.success?
    end

    def error_message
      @error&.message || @data['errors']&.join('\n') || @http_response.status.reason || DEFAULT_ERROR_MESSAGE
    end

    private

    def token
      @token ||= ENV.fetch('API_ENTREPRISE_TOKEN')
    end

    def base_url
      @base_url ||= "https://entreprise.api.gouv.fr/v2/"
    end

    def url_key
      @url_key ||= ""
    end

    def url
      @url ||= "#{base_url}#{url_key}#{@siren_or_siret}?#{request_params}"
    end

    def request_params
      {
        token: token,
        context: 'PlaceDesEntreprises',
        recipient: 'PlaceDesEntreprises',
        object: 'PlaceDesEntreprises'
      }.to_query
    end
  end

  class Responder
    # attr_reader :data

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

  class ApiEntrepriseError < StandardError; end
end