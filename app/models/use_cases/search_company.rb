# frozen_string_literal: true

module UseCases
  class SearchCompany
    class << self
      def with_siret(siret)
        ApiEntrepriseService.fetch_company_with_siret siret
      end

      def with_siret_and_save(siret)
        api_entreprise_result = with_siret(siret)
        return nil if api_entreprise_result.blank?
        company_name = api_entreprise_result['entreprise']['nom_commercial']
        company_name = api_entreprise_result['entreprise']['raison_sociale'] if company_name.blank?
        Company.create! name: company_name.titleize, siren: api_entreprise_result['entreprise']['siren']
      end
    end
  end
end
