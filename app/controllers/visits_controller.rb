# frozen_string_literal: true

class VisitsController < ApplicationController
  def index
    @visits = Visit.of_advisor current_user
  end

  def show
    find_visit
    render layout: 'with_visit_subnavbar'
  end

  def new
    @visit = Visit.new
  end

  def create
    company = UseCases::SearchCompany.with_siret_and_save params[:visit][:siret]
    @visit = Visit.new visit_params
    @visit.assign_attributes advisor: current_user, company: company
    if company && @visit.save
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
    @visit.visitee.added_by_advisor = true
    @visit.visitee.skip_confirmation!
    if @visit.save
      update_visitee_redirection
    else
      render layout: 'with_visit_subnavbar'
    end
  end

  private

  def find_visit
    @visit = Visit.find params[:id]
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
    params.require(:visit).permit(visitee_attributes: %i[first_name last_name email role institution phone_number])
  end
end
