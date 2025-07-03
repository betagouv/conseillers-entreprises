# frozen_string_literal: true

module Api::RechercheEntreprises::Search
  class Fulltext < Api::RechercheEntreprises::Search::Base
  end

  class Request < Api::RechercheEntreprises::Request
  end

  class Responder < Api::RechercheEntreprises::Responder
    # Il peut y avoir plusieurs résultats
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
