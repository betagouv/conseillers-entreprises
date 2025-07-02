module Stats::Needs
  class SubjectsFromExternalCooperation
    include ::Stats::Needs::Concerns::Subjects

    def needs_subjects_base_scope
      needs_base_scope.from_external_cooperation
    end
  end
end
