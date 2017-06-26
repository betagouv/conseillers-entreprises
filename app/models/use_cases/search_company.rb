# frozen_string_literal: true

module UseCases
  class SearchCompany
    class << self
      def with_siret(siret)
        ApiEntrepriseService.fetch_company_with_siret siret
      end

      def with_siren(siren)
        ApiEntrepriseService.fetch_company_with_siren siren
      end
    end
  end
end
