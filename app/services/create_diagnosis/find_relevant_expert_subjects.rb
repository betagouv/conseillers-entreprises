module CreateDiagnosis
  class FindRelevantExpertSubjects
    attr_accessor :need

    def initialize(need)
      @need = need
    end

    def call
      expert_subjects = apply_base_query
      apply_match_filters(expert_subjects)
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

    def apply_match_filters(expert_subjects)
      ids_to_keep = []
      expert_subjects.each do |es|
        if es.match_filters.empty? || es.match_filters.any?{ |mf| accepting(mf) }
          ids_to_keep << es.id
        end
      end
      expert_subjects.where(id: ids_to_keep)
    end

    private

    # Specific filters -------------------------------

    def accepting(match_filter)
      base_filters = [
        accepting_min_years_of_existence(match_filter),
        accepting_effectif(match_filter),
        accepting_naf_codes(match_filter)
      ]
      # Don't verify subject if match_filter is not the same as need subject
      if !match_filter.subject.nil? && need.subject == match_filter.subject
        base_filters << accepting_subject(match_filter)
      end
      base_filters.inject(:&)
    end

    # Ancienneté

    def accepting_min_years_of_existence(match_filter)
      return true if match_filter.min_years_of_existence.blank?
      return false if company.date_de_creation.blank?
      company.date_de_creation.before?(match_filter.min_years_of_existence.years.ago)
    end

    # Sujet

    def accepting_subject(match_filter)
      need.subject == match_filter.subject
    end

    # Effectif

    def accepting_effectif(match_filter)
      [
        accepting_effectif_min(match_filter),
        accepting_effectif_max(match_filter)
      ].inject(:&)
    end

    def accepting_effectif_min(match_filter)
      return true if match_filter.effectif_min.blank?
      return false if facility.effectif.blank?
      facility.effectif > match_filter.effectif_min
    end

    def accepting_effectif_max(match_filter)
      return true if match_filter.effectif_max.blank?
      return false if facility.effectif.blank?
      facility.effectif < match_filter.effectif_max
    end

    # Code naf

    def accepting_naf_codes(match_filter)
      return true if match_filter.accepted_naf_codes.blank?
      match_filter.accepted_naf_codes.include?(facility.naf_code)
    end

    # Helpers -------------------------------

    def facility
      @facility ||= need.facility
    end

    def facility_effectif
      facility.effectif.to_i
    end

    def company
      @company ||= need.company
    end

    def institutions
      @institutions ||= Institution.not_deleted
    end
  end
end
