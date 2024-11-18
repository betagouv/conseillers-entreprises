module DiagnosisCreation
  class CreateAutomaticDiagnosis
    attr_accessor :solicitation, :advisor

    def initialize(solicitation, advisor = nil)
      @solicitation = solicitation
      @advisor = advisor
    end

    def call
      return unless solicitation.may_prepare_diagnosis?

      preparation_errors = nil
      diagnosis = nil
      Diagnosis.transaction do
        creation_result = DiagnosisCreation::CreateOrUpdateDiagnosis.new(
          {
            advisor: advisor,
            solicitation: solicitation,
            facility_attributes: computed_facility_attributes
          }, solicitation.diagnosis
        ).call

        diagnosis = creation_result[:diagnosis]
        DiagnosisCreation::Steps.new(diagnosis).autofill_steps

        preparation_errors = diagnosis.errors.presence || creation_result[:errors].presence
        has_major_error = diagnosis.errors.present? || creation_result.dig(:errors, :major_api_error).present?
        if has_major_error
          diagnosis = nil
          solicitation.diagnosis.destroy if solicitation&.diagnosis&.persisted?
          raise ActiveRecord::Rollback
        end
      end

      solicitation.update(prepare_diagnosis_errors: preparation_errors, diagnosis: diagnosis)
      diagnosis
    end

    private

    def computed_facility_attributes
      if solicitation.siret.present?
        { siret: FormatSiret.clean_siret(solicitation.siret) }
      else
        {
          insee_code: retrieve_insee_code,
          company_attributes: { name: solicitation.full_name }
        }
      end
    end

    def retrieve_insee_code
      # TODO : à revoir quand on aura une meilleure gestion des zones
      query = solicitation.location.parameterize
      Api::Adresse::SearchMunicipality.new(query).call[:insee_code]
    end
  end
end
