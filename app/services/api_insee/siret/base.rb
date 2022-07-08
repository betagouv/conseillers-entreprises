# frozen_string_literal: true

module ApiInsee::Siret
  class Base < ApiInsee::Base
    def request()
      ApiInsee::Siret::Request.new(@siren_or_siret, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end
  end

  class Request < ApiInsee::Request
    private

    def url_key
      @url_key ||= 'siret/'
    end

    def url
      @url ||= "#{base_url}#{url_key}?q=siret:#{@siren_or_siret}"
    end
  end

  class Responder < ApiInsee::Responder
    def format_data
      data = @http_request.data
      etablissements_ouverts = filter_etablissements_ouverts(data["etablissements"])
      entreprise = format_entreprise(data["etablissements"][0])
      {
        entreprise: entreprise,
        nombre_etablissements_ouverts: etablissements_ouverts.size,
        etablissements: data["etablissements"]
      }
    end

    def filter_etablissements_ouverts(etablissements)
      etablissements
        .select { |etablissement| etablissement["periodesEtablissement"][0]["etatAdministratifEtablissement"] == 'A' }
    end

    def format_entreprise(first_etablissement)
      { siren: first_etablissement['siren'] }.merge(first_etablissement['uniteLegale'])
    end
  end
end
