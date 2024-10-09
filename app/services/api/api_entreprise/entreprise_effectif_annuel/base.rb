# frozen_string_literal: true

module Api::ApiEntreprise::EntrepriseEffectifAnnuel
  class Base < Api::ApiEntreprise::Base
    def api_result_key
      "effectifs_entreprise_annuel"
    end
  end

  class Request < Api::ApiEntreprise::Request
    private

    def url_key
      @url_key ||= 'gip_mds/unites_legales/'
    end

    # https://entreprise.api.gouv.fr/v3/gip_mds/unites_legales/{siren}/effectifs_annuels/{year}
    def specific_url
      @specific_url ||= "#{url_key}#{@query}/effectifs_annuels/#{search_year}"
    end

    def search_year
      1.year.ago.year
    end
  end

  class Responder < Api::ApiEntreprise::Responder
    def format_data
      { "effectifs_entreprise_annuel" => @http_request.data['data'] }
    end
  end
end
