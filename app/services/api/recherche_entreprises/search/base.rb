# frozen_string_literal: true

module Api::RechercheEntreprises::Search
  class Base < Api::RechercheEntreprises::Base
  end

  class Request < Api::RechercheEntreprises::Request
    private

    def url_key
      @url_key ||= 'search'
    end

    # On traque pour les collègues d'annuaire entreprise
    def url
      @url ||= "#{base_url}#{url_key}?q=#{@query}&mtm_campaign=conseillers-entreprises"
    end
  end

  class Responder < Api::RechercheEntreprises::Responder
    def format_data
      res = @http_request.data["results"].map do |entreprise|
        siege = entreprise['siege']
        next if (siege["code_pays_etranger"].present? || entreprise['nombre_etablissements_ouverts'] < 1)
        {
          entreprise: entreprise.except('siege'),
          etablissement_siege: entreprise['siege'],
        }
      end
      res.compact
    end
  end
end
