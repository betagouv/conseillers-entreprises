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
      company = Company.find_or_initialize_by siren: siren
      begin
        api_company = ApiConsumption::Company.new(siren, @options).call
        company.update!(
          name: api_company.name,
          date_de_creation: api_company.date_de_creation,
          legal_form_code: api_company.forme_juridique_code,
          code_effectif: api_company.code_effectif,
          effectif: api_company.effectif,
          forme_exercice: api_company.forme_exercice
        )
        @errors.deep_merge!(api_company.errors) if api_company.errors
      rescue Api::TechnicalError, Api::BasicError => e
        if @options[:fallback_insee_code].present?
          if company.name.blank?
            company.update!(name: @options[:fallback_name] || I18n.t("services.create_or_update_facility_and_company.fallback_company_name", siren: siren))
          end
          api_key = e.is_a?(Api::TechnicalError) ? e.api : "api-api-entreprise-entreprise-base"
          @errors[:unreachable_apis] ||= {}
          @errors[:unreachable_apis][api_key] = e.message
        else
          raise e
        end
      end
      company
    end

    def create_or_update_facility(company)
      facility = Facility.find_or_initialize_by siret: @siret
      begin
        api_facility = ApiConsumption::Facility.new(@siret, @options).call
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
      rescue Api::TechnicalError, Api::BasicError => e
        if @options[:fallback_insee_code].present?
          facility.company = company
          if facility.insee_code.blank?
            facility.insee_code = @options[:fallback_insee_code]
          end
          facility.save!
          api_key = e.is_a?(Api::TechnicalError) ? e.api : "api-api-entreprise-etablissement-base"
          @errors[:unreachable_apis] ||= {}
          @errors[:unreachable_apis][api_key] = e.message
        else
          raise e
        end
      end
      facility
    end
  end
end
