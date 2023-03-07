# frozen_string_literal: true

module ApiEntreprise::EntrepriseMandatairesSociaux
  class Base < ApiEntreprise::Base
    def request
      Request.new(@siren_or_siret, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end

    # Retourne hash vide en cas d'erreur
    def handle_error(http_request)
      return { "mandataires sociaux" => { "error" => http_request.error_message } }
    end
  end

  class Request < ApiEntreprise::Request
    private

    def url_key
      @url_key ||= 'infogreffe/rcs/unites_legales/'
    end

    # infogreffe/rcs/unites_legales/{siren}/mandataires_sociaux
    def specific_url
      @specific_url ||= "#{url_key}#{@siren_or_siret}/mandataires_sociaux"
    end
  end

  class Responder < ApiEntreprise::Responder
    def format_data
      { "mandataires_sociaux" => @http_request.data['data'] }
    end
  end
end
