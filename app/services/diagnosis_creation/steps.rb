module DiagnosisCreation
  class Steps
    attr_accessor :diagnosis, :solicitation

    def initialize(diagnosis)
      @diagnosis = diagnosis
      @solicitation = diagnosis.solicitation
    end

    def prepare_happened_on_from_solicitation
      return unless solicitation.present? && diagnosis.happened_on.blank?

      diagnosis.update(happened_on: solicitation.created_at)
      diagnosis
    end

    def prepare_visitee_from_solicitation
      return unless solicitation.present? && diagnosis.visitee.blank?

      diagnosis.build_visitee(full_name: solicitation.full_name,
                         email: solicitation.email,
                         phone_number: solicitation.phone_number,
                         company: diagnosis.facility.company)
      diagnosis.step = :contact
      diagnosis.save # Validate and save both the new visitee and the diagnosis

      diagnosis
    end

    def prepare_needs_from_solicitation
      return unless solicitation.present? && diagnosis.needs.blank?

      subject = solicitation.preselected_subject
      if subject.nil?
        diagnosis.errors.add(:needs, :solicitation_has_no_preselected_subject)
        return diagnosis
      end

      needs_params = { subject: subject }
      need = diagnosis.needs.create(needs_params)
      # On duplique les filtres pour pouvoir les éditer
      solicitation.subject_answers.each do |filter|
        need.subject_answers.push(filter.dup)
      end
      diagnosis.step_needs!

      diagnosis
    end

    def prepare_matches_from_solicitation
      return unless solicitation.present? && diagnosis.matches.blank?
      # on arrete l'analyse à l'étape needs si le sujet de la solicitation est Autre demande
      return if other_subject_solicitation?
      diagnosis.step_matches!

      DiagnosisCreation::CreateMatches.new(diagnosis).call
    end

    def autofill_steps
      # Steps 1, 2, 3: fill in with the solicitation data and the preselections
      prepare_happened_on_from_solicitation if diagnosis.errors.empty?
      prepare_visitee_from_solicitation if diagnosis.errors.empty?
      prepare_needs_from_solicitation if diagnosis.errors.empty?
      prepare_matches_from_solicitation if diagnosis.errors.empty?
    end

    private

    def other_subject_solicitation?
      solicitation.present? && solicitation.landing_subject.subject == Subject.other_need_subject
    end
  end
end
