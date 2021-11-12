# frozen_string_literal: true

module ApiEntreprise::Etablissement::Etablissement
  class Base < ApiEntreprise::Base
    def request
      Request.new(@siren_or_siret)
    end

    def responder(http_request)
      Responder.new(http_request)
    end
  end

  class Request < ApiEntreprise::Request
    private

    def url_key
      @url_key ||= "etablissements/"
    end
  end

  class Responder < ApiEntreprise::Responder
    def format_data
      @http_request.data["etablissement"]
    end
  end
end
