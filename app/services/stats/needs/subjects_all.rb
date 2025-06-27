module Stats::Needs
  class SubjectsAll
    include ::Stats::Needs::Concerns::Subjects

    def needs_subjects_base_scope
      needs_base_scope
    end
  end
end
