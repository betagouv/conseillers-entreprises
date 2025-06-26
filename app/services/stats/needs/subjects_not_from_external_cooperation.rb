module Stats::Needs
  class SubjectsNotFromExternalCooperation
    include ::Stats::Needs::Concerns::Subjects

    def needs_subjects_base_scope
      needs_base_scope.not_from_external_cooperation
    end
  end
end
