# frozen_string_literal: true

class ExpertsController < ApplicationController
  before_action :find_expert, except: :index

  layout 'user_tabs'

  def index
    redirect_to subjects_expert_path(current_user.experts.relevant_for_skills.first)
  end

  def edit
    if !@expert.team?
      redirect_to subjects_expert_path(@expert)
    end
    @user = current_user
  end

  def subjects
    @user = current_user
  end

  def update
    @expert.mark_subjects_reviewed!
    @expert.update(expert_params)
    if expert_params.include?(:experts_subjects_attributes)
      redirect_to subjects_expert_path(@expert)
    else
      redirect_to edit_expert_path(@expert)
    end
  end

  private

  def expert_params
    params.require(:expert).permit(:full_name, :phone_number, :role, :experts_subjects_attributes => {})
  end

  def find_expert
    @expert = Expert.find(params[:id])
    authorize @expert, :update?
  end
end
