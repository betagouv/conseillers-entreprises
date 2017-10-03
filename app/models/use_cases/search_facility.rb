# frozen_string_literal: true

module UseCases
  class SearchFacility
    class << self
      def with_siret(siret)
        token = ENV.fetch('API_ENTREPRISE_TOKEN')
        ApiEntreprise::Etablissements.new(token).fetch(siret)
      end

      def with_siret_and_save(siret)
        company = create_or_update_company(siret)
        create_or_update_facility(siret, company)
      end

      private

      def create_or_update_company(siret)
        api_entreprise_company = UseCases::SearchCompany.with_siret(siret)
        company_name = api_entreprise_company.name
        siren = api_entreprise_company.entreprise['siren']
        legal_form_code = api_entreprise_company.entreprise['forme_juridique_code']
        Company.find_or_create_by! name: company_name.titleize,
                                   siren: siren,
                                   legal_form_code: legal_form_code
      end

      def create_or_update_facility(siret, company)
        api_entreprise_facility = with_siret(siret)
        city_code = api_entreprise_facility.etablissement['commune_implantation']['code']
        naf_code = api_entreprise_facility.etablissement['naf']
        Facility.find_or_create_by! company: company, siret: siret, city_code: city_code, naf_code: naf_code
      end
    end
  end
end
