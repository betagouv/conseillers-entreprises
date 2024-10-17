module DiagnosisCreation
  class PrepareDiagnosis
    attr_accessor :solicitation, :advisor

    def initialize(solicitation, advisor)
      @solicitation = solicitation
      @advisor = advisor
    end

    def call
      return unless solicitation.may_prepare_diagnosis?
      prepare_diagnosis_errors = nil
      diagnosis = nil
      Diagnosis.transaction do
        # Step 0: create with the facility
        diagnosis = DiagnosisCreation::CreateOrUpdateDiagnosis.new(
          {
            advisor: advisor,
            solicitation: solicitation,
            facility_attributes: computed_facility_attributes
          }, solicitation.diagnosis
        ).call

        DiagnosisCreation::Steps.new(diagnosis).autofill_steps

        # Rollback on error!
        if diagnosis.errors.present?
          prepare_diagnosis_errors = diagnosis.errors
          diagnosis = nil
          raise ActiveRecord::Rollback
        end
      end

      # Save or clear the error
      solicitation.update(prepare_diagnosis_errors: prepare_diagnosis_errors, diagnosis: diagnosis)
      return diagnosis
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
