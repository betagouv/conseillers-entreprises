# frozen_string_literal: true

class ExpertsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_expert, except: %i[mes_competences]

  def mes_competences
    if current_user.experts.present?
      redirect_to edit_expert_path(current_user.experts.first)
    else
      redirect_to profile_path
    end
  end

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
    authorize @expert
  end
end
