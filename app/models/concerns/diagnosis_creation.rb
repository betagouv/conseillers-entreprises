module DiagnosisCreation
  # Helper for the diagnosis creation form:
  # Build a new diagnosis with an new facility and company:
  # The creation params hash for a diagnosis has nested attributes for #facility and #facility#company.
  # These will be used `fields_for` form helpers.

  module SolicitationMethods
    # Some preconditions can be verified without actually trying to create the Diagnosis
    def may_prepare_diagnosis?
      self.preselected_subject.present? &&
        FormatSiret.siret_is_valid(FormatSiret.clean_siret(self.siret))
    end

    # Attempt to create a diagnosis up to the last step with the information from the solicitation.
    # Use the preselected attributes (subject & institution) to create the needs and matches.
    #
    # returns nil and sets self.prepare_diagnosis_errors on error.
    # returns the diagnosis on success
    def prepare_diagnosis(advisor)
      return unless may_prepare_diagnosis?

      prepare_diagnosis_errors = nil
      diagnosis = nil
      Diagnosis.transaction do
        # Step 0: create with the facility
        diagnosis = CreateDiagnosis::CreateOrUpdateDiagnosis.new(
          {
            advisor: advisor,
            solicitation: self,
            facility_attributes: computed_facility_attributes
          }, self.diagnosis
        ).call

        diagnosis.autofill_steps

        # Rollback on error!
        if diagnosis.errors.present?
          prepare_diagnosis_errors = diagnosis.errors
          diagnosis = nil
          raise ActiveRecord::Rollback
        end
      end

      # Save or clear the error
      self.update(prepare_diagnosis_errors: prepare_diagnosis_errors, diagnosis: diagnosis)
      diagnosis
    end

    def computed_facility_attributes
      if self.with_siret?
        { siret: FormatSiret.clean_siret(self.siret) }
      else
        {
          insee_code: retrieve_insee_code,
          company_attributes: { name: self.full_name }
        }
      end
    end

    def retrieve_insee_code
      # TODO : à revoir quand on aura une meilleure gestion des zones
      query = location.parameterize
      Api::Adresse::SearchMunicipality.new(query).call[:insee_code]
    end

    ## Store ActiveModel::Errors details as json…
    #
    def prepare_diagnosis_errors=(diagnosis_errors)
      self.prepare_diagnosis_errors_details = diagnosis_errors&.details
    end

    ## … and build a temporary Diagnosis to recreate Errors.
    # This lets us call use the errors in the UI just like regular ActiveModel errors.
    def prepare_diagnosis_errors
      diagnosis_errors = Diagnosis.new.errors

      self.prepare_diagnosis_errors_details&.each do |attr, errors|
        errors.each { |h| h.each_value { |error| diagnosis_errors.add(attr, error.to_sym) } }
      end

      diagnosis_errors
    end

    def with_siret?
      self.siret.present?
    end
  end

  module DiagnosisMethods
    def prepare_needs_from_solicitation
      return unless solicitation.present? && needs.blank?

      subject = solicitation.preselected_subject
      if subject.nil?
        self.errors.add(:needs, :solicitation_has_no_preselected_subject)
        return self
      end

      needs_params = { subject: subject }
      need = self.needs.create(needs_params)
      # On duplique les filtres pour pouvoir les éditer
      solicitation.subject_answers.each do |filter|
        need.subject_answers.push(filter.dup)
      end
      self.step_needs!

      self
    end

    def prepare_happened_on_from_solicitation
      return unless solicitation.present? && happened_on.blank?

      self.update(happened_on: solicitation.created_at)

      self
    end

    def prepare_visitee_from_solicitation
      return unless solicitation.present? && visitee.blank?

      self.build_visitee(full_name: solicitation.full_name,
                         email: solicitation.email,
                         phone_number: solicitation.phone_number,
                         company: facility.company)
      self.step = :contact
      self.save # Validate and save both the new visitee and the diagnosis

      self
    end

    def prepare_matches_from_solicitation
      return unless solicitation.present? && matches.blank?
      # on arrete l'analyse à l'étape needs si le sujet de la solicitation est Autre demande
      return if other_subject_solicitation?
      self.step_matches!

      CreateDiagnosis::CreateMatches.new(self).call
    end

    def autofill_steps
      # Steps 1, 2, 3: fill in with the solicitation data and the preselections
      self.prepare_happened_on_from_solicitation if self.errors.empty?
      self.prepare_visitee_from_solicitation if self.errors.empty?
      self.prepare_needs_from_solicitation if self.errors.empty?
      self.prepare_matches_from_solicitation if self.errors.empty?
    end

    private

    def other_subject_solicitation?
      solicitation.present? && solicitation.landing_subject.subject == Subject.other_need_subject
    end
  end
end
