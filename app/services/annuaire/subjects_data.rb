# frozen_string_literal: true

module Annuaire
  class SubjectsData
    include InstitutionsSubjectsSorter

    # @param institution [Institution]
    def initialize(institution)
      @institution = institution
    end

    def preload
      retrieve_subjects

      self
    end

    # @returns [Hash<Theme, Hash<Subject, Array<InstitutionSubject>>>]
    def grouped_subjects # move to Annuaire::SubjectsData
      @grouped_subjects ||= retrieve_subjects
    end

    # @returns [Array<Theme>]
    def themes
      grouped_subjects.keys
    end

    # @returns [Array<Subject>]
    def subjects
      grouped_subjects.values.map(&:keys).flatten
    end

    # @returns [Array<InstitutionSubject>]
    def institutions_subjects
      grouped_subjects.values.map(&:values).flatten
    end

    def retrieve_subjects
      institutions_subjects_by_theme = @institution.institutions_subjects
        .includes(:subject, :experts_subjects, :not_deleted_experts, :similar_institutions_subjects, theme: [:territorial_zones, :cooperations])
        .strict_loading!
        .sort { |a, b| compare_institution_subjects(a, b) }
        .group_by(&:theme)
        .to_h
      @grouped_subjects = institutions_subjects_by_theme.transform_values{ |is| is.group_by(&:subject) }
    end
  end
end
