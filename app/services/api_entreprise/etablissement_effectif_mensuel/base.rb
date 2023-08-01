# frozen_string_literal: true

module ApiEntreprise::EtablissementEffectifMensuel
  class Base < ApiEntreprise::Base
    def request
      Request.new(@siren_or_siret, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end

    # Retourne hash vide en cas d'erreur
    def handle_error(http_request)
      return { "effectifs_etablissement_mensuel" => { "error" => http_request.error_message } }
    end
  end

  class Request < ApiEntreprise::Request
    private

    def url_key
      @url_key ||= 'gip_mds/etablissements/'
    end

    # https://entreprise.api.gouv.fr/v3/gip_mds/etablissements/{siret}/effectifs_mensuels/{month}/annee/{year}
    def specific_url
      @specific_url ||= "#{url_key}#{@siren_or_siret}/effectifs_mensuels/#{search_month}/annee/#{search_year}"
    end

    def searched_date
      @searched_date ||= Time.zone.now.months_ago(2)
    end

    # il faut un mois avec "0" (08, 09, 10...)
    def search_month
      searched_date.strftime("%m")
    end

    def search_year
      searched_date.year
    end
  end

  class Responder < ApiEntreprise::Responder
    def format_data
      { "effectifs_etablissement_mensuel" => @http_request.data['data'] }
    end
  end
end
