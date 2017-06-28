# frozen_string_literal: true

module UseCases
  class SearchFacility
    class << self
      def with_siret(siret)
        ApiEntrepriseService.fetch_facility_with_siret siret
      end

      def with_siret_and_save(siret)
        api_entreprise_company_result = ApiEntrepriseService.fetch_company_with_siret(siret)
        api_entreprise_facility_result = with_siret(siret)
        return nil if api_entreprise_company_result.blank?
        company_name = ApiEntrepriseService.company_name api_entreprise_company_result
        siren = api_entreprise_company_result['entreprise']['siren']
        company = Company.find_or_create_by! name: company_name.titleize,
                                             siren: siren
        postal_code = api_entreprise_facility_result['etablissement']['commune_implantation']['code']
        Facility.find_or_create_by! company: company, siret: siret, postal_code: postal_code
      end
    end
  end
end
