module Annuaire
  class BaseController < ApplicationController
    before_action :retrieve_institution
    layout 'side_menu'

    def retrieve_institution
      @institution = Institution.find_by(slug: params[:institution_slug])
      authorize @institution

      @institutions_subjects = @institution.institutions_subjects
        .ordered_for_interview
        .preload(:subject, :theme, :experts_subjects, :not_deleted_experts)

      @antennes = @institution.antennes
        .not_deleted
        .order(:name)
        .preload(:communes)

      @advisors = @institution.advisors
        .not_deleted
        .relevant_for_skills
        .joins(:antenne)
        .order('antennes.name', 'team_name', 'users.full_name')
        .preload(:antenne, relevant_expert: [:not_deleted_users, :antenne, :experts_subjects])
    end
  end
end
