# frozen_string_literal: true

module ApiEntreprise
  class EtablissementResponse
    attr_reader :http_response

    DEFAULT_ERROR_MESSAGE = 'There was an error retrieving etablissement details.'

    def initialize(http_response)
      @http_response = http_response
    end

    def success?
      http_response.status == 200
    end

    def error_message
      data&.fetch('message', DEFAULT_ERROR_MESSAGE)
    end

    def etablissement_wrapper
      EtablissementWrapper.new(data)
    end

    private

    def data
      http_response.parse(:json)
    end
  end
end
