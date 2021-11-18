# frozen_string_literal: true

module ApiEntreprise::EntrepriseRm
  class Base < ApiEntreprise::Base
    def request
      Request.new(@siren_or_siret, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end

    # Retourne hash vide en cas d'erreur
    def handle_error(http_request)
      return { "rm" => { "error" => http_request.error_message } }
    end
  end

  class Request < ApiEntreprise::Request
    def error_message
      @error&.message || @data['error'] || @http_response.status.reason || DEFAULT_ERROR_MESSAGE
    end

    private

    def url_key
      @url_key ||= 'entreprises_artisanales_cma/'
    end
  end

  class Responder < ApiEntreprise::Responder
    def format_data
      { "rm" => @http_request.data }
    end
  end
end
