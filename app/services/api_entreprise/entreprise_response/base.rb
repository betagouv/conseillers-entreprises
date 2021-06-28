# frozen_string_literal: true

module ApiEntreprise
  class EntrepriseResponse::Base
    attr_reader :http_response, :data

    DEFAULT_ERROR_MESSAGE = I18n.t('api_entreprise.default_error_message.entreprise')

    def initialize(http_response)
      @http_response = http_response
      begin
        @data = formatted_data
      rescue StandardError => e
        @error = e
      end
    end

    def formatted_data
      http_response.parse(:json)
    end

    def success?
      @error.nil? && @http_response.status.success? && @data['errors'].nil?
    end

    def error_message
      @error&.message || @data['errors'] || @http_response.status.reason || DEFAULT_ERROR_MESSAGE
    end

    def entreprise_wrapper
      EntrepriseWrapper.new(@data)
    end
  end
end
