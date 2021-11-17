module UseCases
  class SearchFacility
    class << self
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
          inscrit_rcs: api_entreprise_company.entreprise.inscrit_rcs,
          inscrit_rm: api_entreprise_company.entreprise.inscrit_rm
        )
        company
      end

      def create_or_update_facility(siret, company, options = {})
        api_facility = ApiConsumption::Facility.new(siret, options).call
        facility = Facility.find_or_initialize_by siret: siret

        facility.update!(
          company: company,
          commune: api_facility.commune,
          naf_code: api_facility.naf,
          readable_locality: api_facility.readable_locality,
          code_effectif: api_facility.code_effectif,
          effectif: api_facility.effectif,
          naf_libelle: api_facility.naf_libelle,
          naf_code_a10: api_facility.naf_code_a10,
          opco: api_facility.opco
        )
        facility
      end
    end
  end
end
