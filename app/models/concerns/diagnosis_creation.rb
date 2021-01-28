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
        facility_params = params.delete(:facility_attributes)
        begin
          # TODO: Get rid of UseCases::SearchFacility and build it implicitely in `facility#siret=`
          #   This would be somewhat magic, but:
          #   * would let us use the params hash as provided.
          #   * remove a lot of machinery
          #   * would just set an error instead of raising an exception.
          #   Related to #622
          params[:facility] = UseCases::SearchFacility.with_siret_and_save(facility_params[:siret])
        rescue ApiEntreprise::ApiEntrepriseError => e
          # Eat the exception and build a Diagnosis object just to hold the error
          diagnosis = Diagnosis.new
          diagnosis.errors.add(:facility, e.message)
          return diagnosis
        end
      end

      params[:step] = :needs
      params[:content] = get_solicitation_description(params)
      Diagnosis.create(params)
    end
  end

  module SolicitationMethods
    # Some preconditions can be verified without actually trying to create the Diagnosis
    def may_prepare_diagnosis?
      self.preselected_subjects.present? &&
        Facility.siret_is_valid(Facility.clean_siret(self.siret)) # TODO: unify the SIRET validation methods
    end

    # Attempt to create a diagnosis up to the last step with the information from the solicitation.
    # Use the landing_option preselected attributes to create the needs and matches.
    #
    # returns nil and sets self.prepare_diagnosis_errors on error.
    # returns the diagnosis on success
    def prepare_diagnosis(advisor)
      return unless may_prepare_diagnosis?

      prepare_diagnosis_errors = nil
      diagnosis = nil
      Diagnosis.transaction do
        # Step 0: create with the facility
        diagnosis = DiagnosisCreation.create_diagnosis(
          advisor: advisor,
          solicitation: self,
          facility_attributes: { siret: Facility.clean_siret(self.siret) }
        )

        # Steps 1, 2, 3: fill in with the solicitation data and the landing_option preselections
        diagnosis.prepare_needs_from_solicitation if diagnosis.errors.empty?
        diagnosis.prepare_happened_on_from_solicitation if diagnosis.errors.empty?
        diagnosis.prepare_visitee_from_solicitation if diagnosis.errors.empty?

        if self.preselected_institutions.present?
          diagnosis.prepare_matches_from_solicitation if diagnosis.errors.empty?
        end

        # Rollback on error!
        if diagnosis.errors.present?
          prepare_diagnosis_errors = diagnosis.errors
          diagnosis = nil
          raise ActiveRecord::Rollback
        end
      end

      # Save or clear the error
      self.update(prepare_diagnosis_errors: prepare_diagnosis_errors)

      diagnosis
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
        errors.each { |h| h.each { |_, error| diagnosis_errors.add(attr, error.to_sym) } }
      end

      diagnosis_errors
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

      institutions = solicitation.preselected_institutions || Institution.not_deleted

      # Note: this query is the very core feature of Place des Entreprises.
      # This is where we find experts for needs.
      self.needs.each do |need|
        expert_subjects = ExpertSubject
          .in_commune(need.facility.commune)
          .of_subject(need.subject)
          .of_institution(institutions)

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

  def self.get_solicitation_description(params)
    if params[:solicitation].present?
      params[:solicitation].description
    elsif params[:solicitation_id].present?
      Solicitation.find(params[:solicitation_id])&.description
    end
  end
end
