module DiagnosisCreation
  # Helper for the diagnosis creation form:
  # Build a new diagnosis with an new facility and company:
  # The creation params hash for a diagnosis has nested attributes for #facility and #facility#company.
  # These will be used `fields_for` form helpers.

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
