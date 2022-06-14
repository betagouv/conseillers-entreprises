module Annuaire
  class SubjectsController < BaseController
    before_action :retrieve_institution

    def index
      @institutions_subjects = @institution.institutions_subjects
        .ordered_for_interview
        .preload(:subject, :theme, :experts_subjects, :not_deleted_experts)
    end
  end
end
