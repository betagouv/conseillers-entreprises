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
    private

    def url_key
      @url_key ||= 'siropartfc/'
    end
  end

  class Responder < ApiFranceCompetence::Responder
    def format_data
      data = @http_request.data.slice('code', 'opcoRattachement', 'opcoGestion')
      return { "opco" => data }
    end
  end
end
