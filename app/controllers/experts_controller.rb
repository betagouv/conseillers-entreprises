# frozen_string_literal: true

class ExpertsController < ApplicationController
  before_action :find_expert, except: :index

  layout 'user_tabs'

  def index
    redirect_to subjects_expert_path(current_user.experts.first)
  end

  def edit
    @user = current_user
  end

  def subjects
    @user = current_user
    @available_expert_subjects = @expert.experts_subjects.available_subjects
    expert_institution_subjects_ids = @available_expert_subjects.pluck(:institution_subject_id)
    @remaining_institution_subjects = @expert.institution.institutions_subjects.available_subjects.where.not(id: expert_institution_subjects_ids)
  end

  def update
    @expert.update(expert_params)
    redirect_to edit_expert_path(@expert), notice: t('.success')
  end

  private

  def expert_params
    params.require(:expert).permit(:phone_number, :job)
  end

  def find_expert
    @expert = Expert.find(params[:id])
    authorize @expert, :update?
  end
end
