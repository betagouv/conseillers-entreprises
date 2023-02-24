# frozen_string_literal: true

module ApiEntreprise::Etablissement
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

    # /v3/insee/sirene/etablissements/diffusibles
    def url_key
      @url_key ||= "insee/sirene/etablissements/diffusibles/"
    end
  end

  class Responder < ApiEntreprise::Responder
    def format_data
      return {
        etablissement: @http_request.data["data"],
        links: @http_request.data["links"],
        meta: @http_request.data["meta"]
      }
    end
  end
end
