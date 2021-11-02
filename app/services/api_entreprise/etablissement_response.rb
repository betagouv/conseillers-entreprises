# frozen_string_literal: true

module ApiEntreprise
  class EtablissementResponse
    attr_reader :http_response, :data

    DEFAULT_ERROR_MESSAGE = I18n.t('api_entreprise.default_error_message.etablissement')

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
      @error&.message || @data['errors']&.join('\n') || @http_response.status.reason || DEFAULT_ERROR_MESSAGE
    end

    def etablissement_wrapper
      EtablissementWrapper.new(@data)
    end
  end
end
