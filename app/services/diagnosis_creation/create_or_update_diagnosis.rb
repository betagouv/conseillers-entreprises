module DiagnosisCreation
  class CreateOrUpdateDiagnosis
    def initialize(params, diagnosis = nil)
      @params = params
      @diagnosis = diagnosis
    end

    def call
      begin
        @diagnosis ||= Diagnosis.new
        Diagnosis.transaction do
          if @params[:facility_attributes].include? :siret
            @params = @params.dup # avoid modifying the params hash at the call site
            # Facility attributes are nested in the hash; if there is no siret, we use the insee_code.
            # In particular, the facility.insee_code= setter will fetch the readable locality name from the geo api.
            facility_params = @params.delete(:facility_attributes)
            @params[:facility] = UseCases::SearchFacility.with_siret_and_save(facility_params[:siret])
          end

          @params[:step] = :contact unless @diagnosis.persisted?
          @params[:content] = solicitation_description
          @diagnosis.attributes = @params
          @diagnosis.save
          @diagnosis
        end
      rescue ::Api::ApiError => e
        # Eat the exception and build a Diagnosis object just to hold the error
        @diagnosis.errors.add(:base, e.message)
        return @diagnosis
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
