# frozen_string_literal: true

class ExpertsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_expert
  before_action :check_user

  def edit
    @is_by_theme = @expert.institution.institutions_subjects
      .ordered_for_interview
      .includes(:theme)
      .group_by { |is| is.theme } # Enumerable#group_by maintains ordering
  end

  def update
    @expert.mark_subjects_reviewed!
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
