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

  module DiagnosisMethods
    def prepare_needs_from_solicitation
      return unless solicitation.present? && needs.blank?

      subjects = solicitation.preselected_subjects
      if subjects.empty?
        self.errors.add(:needs, :solicitation_has_no_preselected_subjects)
        return self
      end

      needs_params = subjects.map{ |s| { subject: s } }
      self.needs.create(needs_params)

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
                          company: facility.company,
                          role: I18n.t('contact.default_role_from_solicitation'))

      self.save # Validate and save both the new visitee and the diagnosis

      self
    end

    def prepare_matches_from_solicitation
      return unless solicitation.present? && matches.blank?

      institutions = solicitation.preselected_institutions || Institution.all

      self.needs.each do |need|
        expert_subjects = ExpertSubject
          .in_commune(need.facility.commune)
          .of_subject(need.subject)
          .of_institution(institutions)
        # do not filter with specialist/fallback here, the institution selection overrides this

        if expert_subjects.present?
          matches_params = expert_subjects.map{ |es| { expert: es.expert, subject: es.subject } }
          need.matches.create(matches_params)
        else
          self.errors.add(:matches, :preselected_institution_has_no_relevant_experts)
        end
      end

      self.matches.reload # self.matches is a through relationship; make sure it’s up to date.

      self
    end
  end
end
