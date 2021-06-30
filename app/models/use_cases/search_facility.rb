module UseCases
  class SearchFacility
    class << self
      def with_siret(siret, options = {})
        token = ENV.fetch('API_ENTREPRISE_TOKEN')
        ApiEntreprise::Etablissements.new(token, options).fetch(siret)
      end

      def with_siret_and_save(siret, options = {})
        company = create_or_update_company(siret, options)
        create_or_update_facility(siret, company, options)
      end

      private

      def create_or_update_company(siret, options = {})
        api_entreprise_company = UseCases::SearchCompany.with_siret(siret, options)
        company_name = api_entreprise_company.name
        siren = api_entreprise_company.entreprise['siren']
        date_de_creation = I18n.l(Time.strptime(api_entreprise_company.entreprise['date_creation'].to_s.to_s, '%s').in_time_zone.to_date)
        legal_form_code = api_entreprise_company.entreprise['forme_juridique_code']
        code_effectif = api_entreprise_company.entreprise.dig('tranche_effectif_salarie_entreprise', 'code')
        company = Company.find_or_initialize_by siren: siren
        company.update!(
          name: company_name,
          legal_form_code: legal_form_code,
          code_effectif: code_effectif,
          date_de_creation: date_de_creation,
          inscrit_rcs: api_entreprise_company.entreprise.inscrit_rcs
        )
        company
      end

      def create_or_update_facility(siret, company, options = {})
        api_entreprise_facility = with_siret(siret, options)
        insee_code = api_entreprise_facility.etablissement['commune_implantation']['code']
        naf_code = api_entreprise_facility.etablissement['naf']
        naf_libelle = api_entreprise_facility.etablissement['libelle_naf']
        naf_code_a10 = NafCode::code_a10(naf_code)
        code_effectif = api_entreprise_facility.etablissement.dig('tranche_effectif_salarie_etablissement', 'code')
        readable_locality = api_entreprise_facility.etablissement.readable_locality
        facility = Facility.find_or_initialize_by siret: siret
        commune = Commune.find_or_create_by insee_code: insee_code
        facility.update! company: company, commune: commune, naf_code: naf_code, readable_locality: readable_locality,
                         code_effectif: code_effectif, naf_libelle: naf_libelle, naf_code_a10: naf_code_a10
        facility
      end
    end
  end
end
