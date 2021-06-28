module Annuaire
  class SubjectsController < BaseController
    def index
      @institutions_subjects = @institution.institutions_subjects
        .ordered_for_interview
        .preload(:subject, :theme, :experts_subjects, :experts)
    end
  end
end
