# frozen_string_literal: true

module ApiEntreprise
  class EntrepriseResponse::Entreprises < EntrepriseResponse::Base
    def formatted_data
      data = http_response.parse(:json)
      {
        entreprise: data["entreprise"],
        etablissement: data["etablissement_siege"],
        errors: data["errors"]
      }
    end
  end
end
