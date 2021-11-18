# frozen_string_literal: true

module ApiEntreprise
  class EntrepriseResponse::Entreprises < EntrepriseResponse::Base
    def formatted_data
      data = @http_response.parse(:json)
      # utilisation de strings pour fournir un json correctement formaté
      return {
        'entreprise' => data["entreprise"],
        'etablissement_siege' => data["etablissement_siege"]
      }
    end
  end
end
