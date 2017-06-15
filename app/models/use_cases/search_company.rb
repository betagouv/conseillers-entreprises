# frozen_string_literal: true

module UseCases
  class SearchCompany
    class << self
      def with_siret(siret)
        ApiEntrepriseService.fetch_company_with_siret siret
      end
    end
  end
end
