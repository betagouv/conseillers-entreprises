# frozen_string_literal: true

module UseCases
  class SearchCompany
    class << self
      def with_siret_and_save(siret:, user:)
        company = with_siret siret
        Search.create! query: siret, user: user, label: lazy_name_of_company(company)
      end

      def with_siret(siret)
        ApiEntrepriseService.fetch_company_with_siret siret
      end

      private

      def lazy_name_of_company(company)
        company['entreprise']['raison_sociale'] if company
      end
    end
  end
end
