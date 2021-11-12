# frozen_string_literal: true

module ApiEntreprise::Etablissement
  class Base < ApiEntreprise::Base
    def request
      Request.new(@siren_or_siret)
    end

    def formatted_response(http_request)
      Response.new(http_request)
    end
  end

  class Request < ApiEntreprise::Request
    private

    def url_key
      @url_key ||= "etablissements/"
    end
  end

  class Response < ApiEntreprise::Response
    def format_data
      @http_request.data["etablissement"]
    end
  end
end
