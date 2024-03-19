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
        expert_subjects = expert_subjects.select do |es|
          adie = Institution.find_by(slug: 'adie')
          initiative = Institution.find_by(slug: 'initiative-france')
          bpi = Institution.find_by(slug: 'bpifrance')
          bdf = Institution.find_by(slug: 'banque-de-france')
          es_institution = es.expert.institution

          # essai de questions liées pour le sujet "Financer sa croissance et ses investissements"
          if ((ENV['FEATURE_QUESTIONS_INVESTISSEMENT'].to_b && es.subject.id == 55) || Rails.env.test?) &&
            (es_institution == adie || es_institution == initiative || es_institution == bpi || es_institution == bdf)
            # on récupère les questions additionnelles liés entre elles
            less_than_10k_question = AdditionalSubjectQuestion.find_by(key: 'moins_de_10k_restant_a_financer')
            bank_question = AdditionalSubjectQuestion.find_by(key: 'financement_bancaire_envisage')
            less_than_10k_institution_filter = need.institution_filters.find_by(additional_subject_question_id: less_than_10k_question.id)
            bank_institution_filter = need.institution_filters.find_by(additional_subject_question_id: bank_question.id)

            # Réponses aux questions
            less_than_10k = less_than_10k_institution_filter.filter_value
            bank = bank_institution_filter.filter_value

            #   moins de 10 000 + oui banque = Adie, Initiative
            #   moins de 10 000 + non banque = Adie
            #   plus de 10 000 + oui banque = Bpi, BDF, Initiative
            #   plus de 10 000 + non banque = BDF, Adie
            if less_than_10k && bank
              es.expert.institution == adie || es.expert.institution == initiative
            elsif less_than_10k && !bank
              es.expert.institution == adie
            elsif !less_than_10k && bank
              es.expert.institution == bpi || es.expert.institution == bdf || es.expert.institution == initiative
            elsif !less_than_10k && !bank
              es.expert.institution == bdf || es.expert.institution == adie
            else
              false
            end

          else
            need_question_id = need_filter.additional_subject_question_id
            need_value = need_filter.filter_value
            institution_filter = es.expert.institution.institution_filters.find_by(additional_subject_question_id: need_question_id)
            # On garde les expert_subjects
            # - qui n'ont pas de filtre sur cette question additionnelle
            # - qui ont la même filter_value que la solicitation
            institution_filter.nil? || (institution_filter.filter_value == need_value)
          end
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
        excluding_naf_codes(match_filter),
        accepting_legal_forms_codes(match_filter),
        excluding_legal_forms_codes(match_filter),
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
  end
end
