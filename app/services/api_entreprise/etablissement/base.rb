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

    def url_key
      @url_key ||= "etablissements/"
    end

    def request_params
      {
        token: token,
        context: 'PlaceDesEntreprises',
        recipient: 'PlaceDesEntreprises',
        object: 'PlaceDesEntreprises',
        non_diffusables: non_diffusables
      }.to_query
    end

    def non_diffusables
      @options[:non_diffusables] || true
    end
  end

  class Responder < ApiEntreprise::Responder
    def format_data
      @http_request.data["etablissement"]
    end
  end
end
