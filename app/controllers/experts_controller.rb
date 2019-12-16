# frozen_string_literal: true

class ExpertsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_expert
  before_action :check_user

  def edit
    @expert.mark_subjects_reviewed!

    @institutions_subjects = @expert.antenne.institution.institutions_subjects
    @es_by_theme = @institutions_subjects.group_by { |is| is.subject.theme }
    @themes = Theme.all.ordered_for_interview
  end

  def update
    @expert.update(expert_params)
    redirect_to profile_path
  end

  private

  def expert_params
    params.require(:expert).permit(:experts_subjects_attributes => {})
  end

  def find_expert
    @expert = Expert.find(params[:id])
  end

  def check_user
    check_current_user_access_to(@expert)
  end
end
