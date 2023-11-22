# frozen_string_literal: true

module ApiFranceCompetence::Siret
  class Base < ApiFranceCompetence::Base
    def request
      ApiFranceCompetence::Siret::Request.new(@siren_or_siret, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end
  end

  class Request < ApiFranceCompetence::Request
    ERROR_CODES = {
      '99' => "Siret Not Found",
      '401' => "API key invalid or expired"
    }.freeze

    def success?
      @error.nil? && response_status.success? && !ERROR_CODES.key?(data['code'])
    end

    def error_message
      @error&.message || ERROR_CODES[data['code']] || @http_response.status.reason || DEFAULT_ERROR_MESSAGE
    end

    private

    def url_key
      @url_key ||= 'siropartfc/'
    end
  end

  class Responder < ApiFranceCompetence::Responder
    def format_data
      data = @http_request.data.slice('code', 'opcoRattachement', 'opcoGestion')
      return { "opco_fc" => data }
    end
  end
end
