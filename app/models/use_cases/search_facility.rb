# frozen_string_literal: true

module UseCases
  class SearchFacility
    class << self
      def with_siret(siret)
        token = ENV.fetch('API_ENTREPRISE_TOKEN')
        ApiEntreprise::Etablissements.new(token).fetch(siret)
      end

      def with_siret_and_save(siret)
        api_entreprise_company = UseCases::SearchCompany.with_siret(siret)
        api_entreprise_facility = with_siret(siret)
        company_name = api_entreprise_company.name
        siren = api_entreprise_company.entreprise['siren']
        company = Company.find_or_create_by! name: company_name.titleize, siren: siren
        city_code = api_entreprise_facility.etablissement['commune_implantation']['code']
        Facility.find_or_create_by! company: company, siret: siret, city_code: city_code
      end
    end
  end
end
