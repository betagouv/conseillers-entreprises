# frozen_string_literal: true

module Api::RechercheEntreprises::Search
  class Siret < Api::RechercheEntreprises::Search::Base
  end

  class Request < Api::RechercheEntreprises::Request
  end

  class Responder < Api::RechercheEntreprises::Responder
    # Un seul résultat ici, et on ne recherche que l'IDCC
    def format_data
      data = @http_request.data.dig("results", 0, "matching_etablissements", 0)
      {
        liste_idcc: data&.dig("liste_idcc"),
      }
    end
  end
end
