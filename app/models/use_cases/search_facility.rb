module UseCases
  class SearchFacility
    class << self
      def with_siret_and_save(siret, options = {})
        company = create_or_update_company(siret, options)
        create_or_update_facility(siret, company, options)
      end

      private

      def create_or_update_company(siret, options = {})
        siren = siret[0, 9]
        api_company = ApiConsumption::Company.new(siren, options).call
        company = Company.find_or_initialize_by siren: siren
        company.update!(
          name: api_company.name,
          date_de_creation: api_company.date_de_creation,
          legal_form_code: api_company.forme_juridique_code,
          code_effectif: api_company.code_effectif,
          effectif: api_company.effectif,
          inscrit_rcs: api_company.inscrit_rcs,
          inscrit_rm: api_company.inscrit_rm
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
