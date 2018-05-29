# frozen_string_literal: true

module ApiEntreprise
  class EtablissementResponse
    attr_reader :http_response

    DEFAULT_ERROR_MESSAGE = 'There was an error retrieving etablissement details.'

    def initialize(http_response)
      @http_response = http_response
      begin
        @data = http_response.parse(:json)
      rescue StandardError => error
        @error = error
      end
    end

    def success?
      @error.nil? && @http_response.status.success?
    end

    def error_message
      @error&.message || @data['errors'] || @http_response.status.reason || DEFAULT_ERROR_MESSAGE
    end

    def etablissement_wrapper
      EtablissementWrapper.new(@data)
    end

  end
end
