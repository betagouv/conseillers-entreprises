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
        company = Company.find_or_initialize_by siren: siren
        company.update! name: company_name, legal_form_code: legal_form_code
        company
      end

      def create_or_update_facility(siret, company)
        api_entreprise_facility = with_siret(siret)
        insee_code = api_entreprise_facility.etablissement['commune_implantation']['code']
        naf_code = api_entreprise_facility.etablissement['naf']
        readable_locality = api_entreprise_facility.etablissement.readable_locality
        facility = Facility.find_or_initialize_by siret: siret
        commune = Commune.find_or_create_by insee_code: insee_code
        facility.update! company: company, commune: commune, naf_code: naf_code, readable_locality: readable_locality
        facility
      end
    end
  end
end
