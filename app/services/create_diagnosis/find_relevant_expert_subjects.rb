module CreateDiagnosis
  class FindRelevantExpertSubjects
    attr_accessor :need

    def initialize(need)
      @need = need
    end

    def call
      expert_subjects = apply_base_query
      [
        apply_match_filters(expert_subjects),
        apply_subject_question_filters(expert_subjects),
        apply_special_landings(expert_subjects)
      ].reduce(:&)
    end

    def apply_special_landings(expert_subjects)
      expert_subjects.reject do |es|
        # Experimentation TEE : on enlève l'ADEME si ca vient pas de la landing TEE
        es.expert.id == 22483 && !from_landing('transition-ecologique-entreprises-api')
      end
    end

    def apply_base_query
      ExpertSubject
        .joins(:not_deleted_expert)
        .in_commune(facility.commune)
        .of_subject(need.subject)
        .of_institution(institutions)
        .without_irrelevant_chambres(facility)
        .without_irrelevant_opcos(facility)
    end

    def apply_subject_question_filters(expert_subjects)
      expert_subjects.select do |es|
        # On n'examine que les filtres qui concernent le sujet
        institution_answer_groupings = es.expert.institution.subject_answer_groupings.by_subject(need.subject)
        institution_answer_groupings.empty? || institution_answer_groupings.any?{ |ag| accepting_subject_answers(ag) }
      end
    end

    def apply_match_filters(expert_subjects)
      expert_subjects.select do |es|
        # On retire les filtres sur les sujets autres que celui du besoin
        examined_match_filters = es.match_filters.reject{ |mf| other_subject_filter?(mf) }
        # On retire les filtres aux institutions si on a le même filtre à une antenne ou expert
        examined_match_filters = examined_match_filters.reject do |mf|
          mf.same_antenne_or_expert_match_filter?(examined_match_filters)
        end
        # On retire les filtres aux antennes si on a le même filtre à un expert
        # En deux étapes pour éviter de supprimer tous les filtres dans une même boucle
        examined_match_filters = examined_match_filters.reject do |mf|
          mf.same_expert_match_filter?(examined_match_filters)
        end
        # On garde les experts_subjects
        # - qui n'ont pas de filtres
        # - ou bien où au moins un filtre passe
        examined_match_filters.empty? || examined_match_filters.any?{ |mf| accepting_match_filter(mf) }
      end
    end

    private

    # Specific filters -------------------------------

    def accepting_match_filter(match_filter)
      base_filters = [
        accepting_years_of_existence(match_filter),
        accepting_effectif(match_filter),
        accepting_naf_codes(match_filter),
        excluding_naf_codes(match_filter),
        accepting_legal_forms_codes(match_filter),
        excluding_legal_forms_codes(match_filter),
      ]
      base_filters.reduce(:&)
    end

    def accepting_subject_answers(institution_answer_grouping)
      institution_answer_grouping.subject_answers.each do |institution_answer|
        question_id = institution_answer.subject_question_id
        need_answer = need.subject_answers.find_by(subject_question_id: question_id)
        # On garde les expert_subjects qui ont la même filter_value que la solicitation
        raise FilterError if need_answer.present? && (institution_answer.filter_value != need_answer.filter_value)
      end
      return true
    rescue FilterError
      return false
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

    def excluding_naf_codes(match_filter)
      return true if match_filter.excluded_naf_codes.blank?
      match_filter.excluded_naf_codes.exclude?(facility.naf_code)
    end

    # Forme juridique

    def accepting_legal_forms_codes(match_filter)
      return true if match_filter.accepted_legal_forms.blank?
      match_filter.accepted_legal_forms.include?(company.legal_form_code)
    end

    def excluding_legal_forms_codes(match_filter)
      return true if match_filter.excluded_legal_forms.blank?
      match_filter.excluded_legal_forms.exclude?(company.legal_form_code)
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

    def from_landing(slug)
      need.solicitation&.landing&.slug == slug
    end
  end

  class FilterError < StandardError; end
end
