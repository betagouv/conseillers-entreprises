# frozen_string_literal: true

module Api::ApiEntreprise::EntrepriseMandatairesSociaux
  class Base < Api::ApiEntreprise::Base
    # Retourne hash vide en cas d'erreur
    def handle_error(http_request)
      if http_request.has_tech_error?
        notify_tech_error(http_request)
      end
      return { "mandataires sociaux" => { "error" => http_request.error_message } }
    end
  end

  class Request < Api::ApiEntreprise::Request
    private

    def url_key
      @url_key ||= 'infogreffe/rcs/unites_legales/'
    end

    # infogreffe/rcs/unites_legales/{siren}/mandataires_sociaux
    def specific_url
      @specific_url ||= "#{url_key}#{@siren_or_siret}/mandataires_sociaux"
    end
  end

  class Responder < Api::ApiEntreprise::Responder
    def format_data
      { "mandataires_sociaux" => @http_request.data['data'] }
    end
  end
end
