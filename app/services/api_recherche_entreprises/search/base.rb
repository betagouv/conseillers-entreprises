# frozen_string_literal: true

module ApiRechercheEntreprises::Search
  class Base < ApiRechercheEntreprises::Base
    def request
      Request.new(@query, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end
  end

  class Request < ApiRechercheEntreprises::Request
    private

    def url_key
      @url_key ||= 'search'
    end

    def url
      @url ||= "#{base_url}#{url_key}?q=#{@query}"
    end
  end

  class Responder < ApiRechercheEntreprises::Responder
    def format_data
      entreprises = []
      @http_request.data["results"].map do |entreprise|
        siege = entreprise['siege']
        next if (siege["code_pays_etranger"].present? || entreprise['nombre_etablissements_ouverts'] < 1)
        etablissements = [
          {
            siret: siege['siret'],
            code_postal: siege['code_postal'],
            libelle_commune: siege['libelle_commune'],
            code_ape: siege['activite_principale'],
            siege_social: true
          }
        ]
        entreprises.push(
          {
            siren: entreprise['siren'],
            nom: entreprise['nom_complet'],
            nombre_etablissements_ouverts: entreprise['nombre_etablissements_ouverts'],
            etablissements: etablissements
          }
        )
      end
      return { entreprises: entreprises }
    end
  end
end
