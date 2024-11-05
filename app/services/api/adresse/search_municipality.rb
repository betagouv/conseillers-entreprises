# frozen_string_literal: true

module Api::Adresse
  class SearchMunicipality < Api::Base
    def initialize(location)
      @location = location
    end

    def call
      Rails.cache.fetch(['location', @location].join('-'), expires_in: 12.hours) do
        http_request = Request.new(@location)
        if http_request.success?
          responder(http_request).call
        else
          handle_error(http_request)
        end
      end
    end
  end

  class Request < Api::Request
    CLIENT_HTTP_ERRORS = [401, 403]
    DEFAULT_ERROR_MESSAGE = I18n.t('api_requests.default_error_message.etablissement')

    attr_reader :data

    def initialize(location)
      @location = location
      begin
        @http_response = HTTP.get(url)
        @data = @http_response.parse(:json)
      rescue StandardError => e
        @error = e
      end
    end

    def data_error_message
      @data['message'] || @data['searchStatus']
    end

    def api_result_key
      "search_municipality"
    end

    private

    def base_url
      @base_url ||= 'https://api-adresse.data.gouv.fr/search/?type=municipality&q='
    end

    def url
      @url ||= [base_url, @location].join
    end
  end

  class Responder < Api::Responder
    def format_data
      { insee_code: @http_request.data.dig("features", 0, "properties", "id") }
    end
  end
end
