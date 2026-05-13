# frozen_string_literal: true

module Api::RechercheEntreprises::Search::Fulltext
  class Base < Api::RechercheEntreprises::Search::Base
  end

  class Request < Api::RechercheEntreprises::Search::Request
    def initialize(query, options = {})
      raise Api::BasicError, I18n.t("api_requests.too_short", min_length: 3) if query.size < 3
      super
    end
  end

  class Responder < Api::RechercheEntreprises::Search::Responder
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
