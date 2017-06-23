# frozen_string_literal: true

class VisitsController < ApplicationController
  def index
    @visits = Visit.of_advisor(current_user).includes(:facility)
  end

  def show
    find_visit
    @facility = UseCases::SearchFacility.with_siret @visit.facility.siret
    render layout: 'with_visit_subnavbar'
  end

  def new
    @visit = Visit.new
  end

  def create
    facility = UseCases::SearchFacility.with_siret_and_save params[:visit][:siret]
    @visit = Visit.new visit_params
    @visit.assign_attributes advisor: current_user, facility: facility
    if facility && @visit.save
      redirect_to visit_path @visit
    else
      render 'new'
    end
  end

  def edit_visitee
    find_visit
    @visit.build_visitee
    render layout: 'with_visit_subnavbar'
  end

  def update_visitee
    find_visit
    @visit.assign_attributes update_visitee_params
    @visit.visitee.company = @visit.facility.company
    if @visit.save
      update_visitee_redirection
    else
      render 'edit_visitee', layout: 'with_visit_subnavbar'
    end
  end

  private

  def find_visit
    @visit = Visit.of_advisor(current_user).includes([:facility, :diagnoses]).find params[:id]
  end

  def update_visitee_redirection
    if params[:question_id].present?
      redirect_to question_visit_diagnosis_index_path(visit_id: @visit.id, id: params[:question_id])
    else
      redirect_to visit_path(@visit)
    end
  end

  def visit_params
    params.require(:visit).permit(:happened_at)
  end

  def update_visitee_params
    params.require(:visit).permit(visitee_attributes: %i[full_name role email phone_number])
  end
end
