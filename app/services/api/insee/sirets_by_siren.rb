module Api::Insee::SiretsBySiren
  class Base < Api::Insee::Base
  end

  class Request < Api::Insee::Request
    private

    def url_key
      @url_key ||= 'siret/'
    end

    def url
      @url ||= "#{base_url}#{url_key}?q=siren:#{@query}"
    end
  end

  class Responder < Api::Insee::Responder
    def format_data
      data = @http_request.data
      etablissements_ouverts = filter_etablissements_ouverts(data["etablissements"])
      entreprise = format_entreprise(data["etablissements"][0])
      {
        entreprise: entreprise,
        etablissements_ouverts: etablissements_ouverts,
        nombre_etablissements_ouverts: etablissements_ouverts.size,
      }
    end

    # On ne garde que les établissements ouverts et en France
    def filter_etablissements_ouverts(etablissements)
      etablissements
        .select { |etablissement| etablissement["periodesEtablissement"][0]["etatAdministratifEtablissement"] == 'A' }
        .select { |etablissement| etablissement['adresseEtablissement']["libellePaysEtrangerEtablissement"] == nil }
    end

    def format_entreprise(first_etablissement)
      { siren: first_etablissement['siren'] }.merge(first_etablissement['uniteLegale'])
    end
  end
end
