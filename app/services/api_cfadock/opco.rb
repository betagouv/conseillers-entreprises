# frozen_string_literal: true

module ApiCfadock
  class Opco
    def initialize(siret)
      @siret = FormatSiret.clean_siret(siret)
      return unless FormatSiret.siret_is_valid(@siret)
    end

    def call
      Rails.cache.fetch(['opco', @siret].join('-'), expires_in: 12.hours) do
        http_request = Request.new(@siret)
        if http_request.success?
          Responder.new(http_request).call
        else
          return { "opco" => { "error" => http_request.error_message } }
        end
      end
    end
  end

  class Request
    BASE_URL = 'https://www.cfadock.fr/api/opcos?siret='
    DEFAULT_ERROR_MESSAGE = I18n.t('api_entreprise.default_error_message.etablissement')

    attr_reader :data

    def initialize(siret)
      @siret = siret
      @http_response = HTTP.get(url)
      begin
        @data = @http_response.parse(:json)
      rescue StandardError => e
        @error = e
      end
    end

    def success?
      @error.nil? && @http_response.status.success? && @http_response.parse(:json)["searchStatus"] == "OK"
    end

    def error_message
      @error&.message || @data['searchStatus'] || @http_response.status.reason || DEFAULT_ERROR_MESSAGE
    end

    private

    def url
      @url ||= [BASE_URL, @siret].join
    end
  end

  class Responder
    attr_reader :data

    def initialize(http_request)
      @http_request = http_request
    end

    def call
      @data = @http_request.data.slice('idcc', 'opcoName', 'opcoSiren')
    end
  end

  class CfadockError < StandardError; end
end
