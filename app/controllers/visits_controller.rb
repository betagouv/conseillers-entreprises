# frozen_string_literal: true

class VisitsController < ApplicationController
  def show
    find_visit
    @facility = UseCases::SearchFacility.with_siret @visit.facility.siret
  end

  def edit_visitee
    find_visit
    @visit.build_visitee
  end

  def update_visitee
    find_visit
    @visit.assign_attributes update_visitee_params
    @visit.visitee.company = @visit.facility.company
    if @visit.save
      update_visitee_redirection
    else
      render 'edit_visitee'
    end
  end

  private

  def find_visit
    @visit = Visit.of_advisor(current_user).includes(%i[facility]).find params[:id]
  end

  def update_visitee_redirection
    if params[:diagnosis_id].present?
      redirect_to visit_diagnosis_path(visit_id: @visit.id, id: params[:diagnosis_id])
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
