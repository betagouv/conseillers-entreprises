# frozen_string_literal: true

module Api::RechercheEntreprises::Search::Siret
  class Base < Api::RechercheEntreprises::Search::Base
  end

  class Request < Api::RechercheEntreprises::Search::Request
  end

  class Responder < Api::RechercheEntreprises::Search::Responder
    # Un seul résultat ici, et on ne recherche que l'IDCC
    def format_data
      data = @http_request.data.dig("results", 0, "matching_etablissements", 0)
      {
        liste_idcc: data&.dig("liste_idcc"),
      }
    end
  end
end
