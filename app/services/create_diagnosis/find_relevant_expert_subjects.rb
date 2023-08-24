module CreateDiagnosis
  class FindRelevantExpertSubjects
    attr_accessor :need

    def initialize(need)
      @need = need
    end

    def call
      expert_subjects = apply_base_query
      [
        apply_institution_filters(expert_subjects),
        apply_match_filters(expert_subjects)
      ].reduce(:&)
    end

    def apply_base_query
      ExpertSubject
        .joins(:not_deleted_expert)
        .in_commune(facility.commune)
        .of_subject(need.subject)
        .of_institution(institutions)
        .in_company_registres(company)
        .without_irrelevant_opcos(facility)
    end

    def apply_institution_filters(expert_subjects)
      need.institution_filters.each do |need_filter|
        need_question_id = need_filter.additional_subject_question_id
        need_value = need_filter.filter_value
        expert_subjects = expert_subjects.select do |es|
          institution_filter = es.expert.institution.institution_filters.find_by(additional_subject_question_id: need_question_id)
          # On garde les expert_subjects
          # - qui n'ont pas de filtre sur cette question additionnelle
          # - qui ont la même filter_value que la solicitation
          institution_filter.nil? || (institution_filter.filter_value == need_value)
        end
      end
      expert_subjects
    end

    def apply_match_filters(expert_subjects)
      expert_subjects.select do |es|
        # On retire les filtres sur les sujets autres que celui du besoin
        examined_match_filters = es.match_filters.reject{ |mf| other_subject_filter?(mf) }
        # On garde les experts_subjects
        # - qui n'ont pas de filtres
        # - ou bien où au moins un filtre passe
        examined_match_filters.empty? || examined_match_filters.any?{ |mf| accepting(mf) }
      end
    end

    private

    # Specific filters -------------------------------

    def accepting(match_filter)
      base_filters = [
        accepting_years_of_existence(match_filter),
        accepting_effectif(match_filter),
        accepting_naf_codes(match_filter),
        accepting_legal_forms_codes(match_filter)
      ]
      base_filters.reduce(:&)
    end

    # Sujet

    def other_subject_filter?(match_filter)
      match_filter.subjects.any? && match_filter.subjects.exclude?(need.subject)
    end

    # Ancienneté

    def accepting_years_of_existence(match_filter)
      [
        accepting_min_years_of_existence(match_filter),
        accepting_max_years_of_existence(match_filter)
      ].reduce(:&)
    end

    def accepting_min_years_of_existence(match_filter)
      return true if match_filter.min_years_of_existence.blank?
      return false if company.date_de_creation.blank?
      company.date_de_creation.before?(match_filter.min_years_of_existence.years.ago)
    end

    def accepting_max_years_of_existence(match_filter)
      return true if match_filter.max_years_of_existence.blank?
      return false if company.date_de_creation.blank?
      company.date_de_creation.after?(match_filter.max_years_of_existence.years.ago)
    end

    # Effectif

    def accepting_effectif(match_filter)
      [
        accepting_effectif_min(match_filter),
        accepting_effectif_max(match_filter)
      ].reduce(:&)
    end

    def accepting_effectif_min(match_filter)
      return true if match_filter.effectif_min.blank?
      return false if facility.code_effectif.blank?
      facility_code_effectif.min_bound >= match_filter.effectif_min
    end

    def accepting_effectif_max(match_filter)
      return true if match_filter.effectif_max.blank?
      return false if facility.code_effectif.blank?
      facility_code_effectif.max_bound < match_filter.effectif_max
    end

    def facility_code_effectif
      Effectif::CodeEffectif.new(facility.code_effectif)
    end

    # Code naf

    def accepting_naf_codes(match_filter)
      return true if match_filter.accepted_naf_codes.blank?
      match_filter.accepted_naf_codes.include?(facility.naf_code)
    end

    # Forme juridique

    def accepting_legal_forms_codes(match_filter)
      return true if match_filter.accepted_legal_forms.blank?
      match_filter.accepted_legal_forms.include?(company.legal_form_code&.first)
    end

    # Helpers -------------------------------

    def facility
      @facility ||= need.facility
    end

    def company
      @company ||= need.company
    end

    def institutions
      @institutions ||= Institution.not_deleted
    end

    def solicitation
      @solicitation ||= need.solicitation
    end
  end
end
