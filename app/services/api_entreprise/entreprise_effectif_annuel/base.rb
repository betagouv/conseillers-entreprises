# frozen_string_literal: true

module ApiEntreprise::EntrepriseEffectifAnnuel
  class Base < ApiEntreprise::Base
    def request
      Request.new(@siren_or_siret, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end

    # Retourne hash vide en cas d'erreur
    def handle_error(http_request)
      return { "effectifs-entreprise-annuel" => { "error" => http_request.error_message } }
    end
  end

  class Request < ApiEntreprise::Request
    private

    def url_key
      @url_key ||= 'gip_mds/unites_legales/'
    end

    # https://entreprise.api.gouv.fr/v3/gip_mds/unites_legales/{siren}/effectifs_annuels/{year}
    def specific_url
      @specific_url ||= "#{url_key}/#{@siren_or_siret}/effectifs_annuels/#{search_year}"
    end

    def search_year
      1.year.ago.year
    end
  end

  class Responder < ApiEntreprise::Responder
    def format_data
      { "effectifs-entreprise-annuel" => @http_request.data }
    end
  end
end
