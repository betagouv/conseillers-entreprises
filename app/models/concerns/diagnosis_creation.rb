module DiagnosisCreation
  # Helper for the diagnosis creation form:
  # Build a new diagnosis with an new facility and company:
  # The creation params hash for a diagnosis has nested attributes for #facility and #facility#company.
  # These will be used `fields_for` form helpers.
  def self.new_diagnosis(solicitation)
    Diagnosis.new(solicitation: solicitation,
                  facility: Facility.new(company: Company.new(name: solicitation&.full_name)))
  end

  # Actually create a diagnosis with nested attributes for #facility and #company
  def self.create_diagnosis(params)
    Diagnosis.transaction do
      if params[:facility_attributes].include? :siret
        params = params.dup # avoid modifying the params hash at the call site
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
