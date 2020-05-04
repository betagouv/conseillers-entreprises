module DiagnosisCreation
  # Helpers for diagnosis creation forms:
  # The creation params hash for a diagnosis has nested attributes for #facility and #facility#company.
  # Build a new diagnosis with an new facility and company:
  # These will be used `fields_for` form helpers.
  def self.new_diagnosis(solicitation)
    Diagnosis.new(solicitation: solicitation,
                  facility: Facility.new(company: Company.new(name: solicitation&.full_name)))
  end

  def self.create_diagnosis(params)
    Diagnosis.transaction do
      if params[:facility_attributes].include? :siret
        # Facility attributes are nested in the hash; if there is no siret, we use the insee_code.
        # In particular, the facility.insee_code= setter will fetch the readable locality name from the geo api.
        # TODO: Get rid of UseCases::SearchFacility and handle implicitely in `facility#siret=`,
        # This would let us use the params hash as provided.
        facility_params = params.delete(:facility_attributes)
        params[:facility] = UseCases::SearchFacility.with_siret_and_save(facility_params[:siret])
      end

      params[:step] = :needs
      Diagnosis.create(params)
    end
  end
end
