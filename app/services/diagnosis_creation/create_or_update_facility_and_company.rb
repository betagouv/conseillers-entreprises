module DiagnosisCreation
  class CreateOrUpdateFacilityAndCompany
    def initialize(siret, options = {})
      @siret = siret
      @options = options
      @errors = {}
    end

    def call
      company = create_or_update_company
      facility = create_or_update_facility(company)
      return {
        facility: facility,
        errors: @errors
      }
    end

    private

    def create_or_update_company
      siren = @siret[0, 9]
      api_company = ApiConsumption::Company.new(siren, @options).call
      company = Company.find_or_initialize_by siren: siren
      company.update!(
        name: api_company.name,
        date_de_creation: api_company.date_de_creation,
        legal_form_code: api_company.forme_juridique_code,
        code_effectif: api_company.code_effectif,
        effectif: api_company.effectif,
        forme_exercice: api_company.forme_exercice
      )
      @errors.deep_merge!(api_company.errors) if api_company.errors
      company
    end

    def create_or_update_facility(company)
      api_facility = ApiConsumption::Facility.new(@siret, @options).call
      facility = Facility.find_or_initialize_by siret: @siret
      facility.update!(
        company: company,
        insee_code: api_facility.insee_code,
        naf_code: api_facility.naf_code,
        readable_locality: api_facility.readable_locality,
        code_effectif: api_facility.code_effectif,
        effectif: api_facility.effectif,
        naf_libelle: api_facility.naf_libelle,
        naf_code_a10: api_facility.naf_code_a10,
        opco: api_facility.opco,
        nature_activites: api_facility.nature_activites,
        nafa_codes: api_facility.nafa_codes
      )
      @errors.deep_merge!(api_facility.errors) if api_facility.errors
      facility
    end
  end
end
