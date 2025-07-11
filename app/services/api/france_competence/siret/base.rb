# frozen_string_literal: true

module Api::FranceCompetence::Siret
  class Base < Api::FranceCompetence::Base
  end

  class Request < Api::FranceCompetence::Request
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

    # Mise en sommeil temporaire pour arrêter le pop des erreurs aux bizdev, a supprimer qd ça remarche
    def has_unreachable_api_error?
      false
    end

    private

    def url_key
      @url_key ||= 'siropartfc/v1/api/partenaire/'
    end
  end

  class Responder < Api::FranceCompetence::Responder
    def format_data
      data = @http_request.data.slice('code', 'opcoRattachement', 'opcoGestion')
      return { "opco_fc" => data }
    end
  end
end
