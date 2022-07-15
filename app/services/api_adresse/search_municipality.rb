# frozen_string_literal: true

module ApiAdresse
  class SearchMunicipality
    def initialize(location)
      @location = location
    end

    def call
      Rails.cache.fetch(['location', @location].join('-'), expires_in: 12.hours) do
        http_request = Request.new(@location)
        if http_request.success?
          Responder.new(http_request).call
        else
          return { "search_municipality" => { "error" => http_request.error_message } }
        end
      end
    end
  end

  class Request
    BASE_URL = 'https://api-adresse.data.gouv.fr/search/?type=municipality&q='
    DEFAULT_ERROR_MESSAGE = I18n.t('api_requests.default_error_message.etablissement')

    attr_reader :data

    def initialize(location)
      @location = location
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
      @error&.message || @data['searchStatus'] || @http_response.status.reason || DEFAULT_ERROR_MESSAGE
    end

    private

    def url
      @url ||= [BASE_URL, @location].join
    end
  end

  class Responder
    def initialize(http_request)
      @http_request = http_request
    end

    def call
      { insee_code: @http_request.data.dig("features", 0, "properties", "id") }
    end
  end
end
