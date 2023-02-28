# frozen_string_literal: true

module ApiEntreprise::Entreprise
  class Base < ApiEntreprise::Base
    def request
      Request.new(@siren_or_siret, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end
  end

  class Request < ApiEntreprise::Request
    private

    # /v3/insee/sirene/unites_legales/{siren}
    def url_key
      @url_key ||= 'insee/sirene/unites_legales/'
    end
  end

  class Responder < ApiEntreprise::Responder
    def format_data
      return {
        entreprise: @http_request.data["data"],
        links: @http_request.data["links"],
        meta: @http_request.data["meta"]
      }
    end
  end
end
