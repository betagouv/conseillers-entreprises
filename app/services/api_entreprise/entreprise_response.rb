# frozen_string_literal: true

module ApiEntreprise
  class EntrepriseResponse
    attr_reader :http_response

    DEFAULT_ERROR_MESSAGE = 'There was an error retrieving entreprise details.'

    def initialize(http_response)
      @http_response = http_response
      begin
        @data = http_response.parse(:json)
      rescue StandardError => e
        @error = e
      end
    end

    def success?
      @error.nil? && @http_response.status.success?
    end

    def error_message
      @error&.message || @data['errors'] || @http_response.status.reason || DEFAULT_ERROR_MESSAGE
    end

    def entreprise_wrapper
      EntrepriseWrapper.new(@data)
    end
  end
end
