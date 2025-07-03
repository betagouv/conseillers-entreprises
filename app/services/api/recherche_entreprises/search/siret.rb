# frozen_string_literal: true

module Api::RechercheEntreprises::Search
  class Siret < Api::RechercheEntreprises::Search::Base
  end

  class Request < Api::RechercheEntreprises::Request
  end

  class Responder < Api::RechercheEntreprises::Responder
    # Un seul résultat ici
    def format_data
      @http_request.data["results"].first
    end
  end
end
