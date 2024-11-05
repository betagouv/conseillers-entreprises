module DiagnosisCreation
  class CreateOrUpdateDiagnosis
    def initialize(params, diagnosis = nil)
      @params = params
      @diagnosis = diagnosis || Diagnosis.new
      @errors = {}
    end

    def call
      begin
        Diagnosis.transaction do
          if @params[:facility_attributes].include? :siret
            @params = @params.dup # avoid modifying the params hash at the call site
            # Facility attributes are nested in the hash; if there is no siret, we use the insee_code.
            # In particular, the facility.insee_code= setter will fetch the readable locality name from the geo api.
            facility_params = @params.delete(:facility_attributes)
            facility_api_result = DiagnosisCreation::CreateOrUpdateFacilityAndCompany.new(facility_params[:siret]).call
            @params[:facility] = facility_api_result[:facility]
            @errors.deep_merge!(facility_api_result[:errors])
          end

          @params[:step] = :contact unless @diagnosis.persisted?
          @params[:content] = solicitation_description
          @diagnosis.attributes = @params
          @diagnosis.save
          {
            diagnosis: @diagnosis,
            errors: @errors
          }
        end
      rescue Api::TechnicalError => e
        return {
          diagnosis: @diagnosis,
          errors: { e.severity => { e.api => e.message } }
        }
      rescue Api::BasicError => e
        return {
          diagnosis: @diagnosis,
          errors: { standard: e.message }
        }
      end
    end

    private

    def solicitation_description
      if @params[:solicitation].present?
        @params[:solicitation].description
      elsif @params[:solicitation_id].present?
        Solicitation.find(@params[:solicitation_id])&.description
      end
    end
  end
end
