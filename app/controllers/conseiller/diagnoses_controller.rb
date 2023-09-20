# frozen_string_literal: true

class Conseiller::DiagnosesController < ApplicationController
  before_action :retrieve_diagnosis, only: :show
  def new
    authorize Diagnosis
    @current_solicitation = Solicitation.find_by(id: params[:solicitation])
    @diagnosis = DiagnosisCreation.new_diagnosis(@current_solicitation)
    if @current_solicitation.present?
      @needs = Need.for_emails_and_sirets([@current_solicitation&.email], [@current_solicitation&.siret])
      @tab = 'search_manually' if @current_solicitation.siret.nil?
    else
      @needs = []
    end
  end

  def create
    @diagnosis = DiagnosisCreation.create_diagnosis(diagnosis_params.merge(advisor: current_user))

    if @diagnosis.persisted?
      @diagnosis.autofill_steps
      redirect_to controller: 'conseiller/diagnoses/steps', action: @diagnosis.step, id: @diagnosis
    else
      flash.now[:alert] = @diagnosis.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @diagnosis
    if @diagnosis.step_completed?
      need = current_user.received_needs.where(diagnosis: @diagnosis).first || @diagnosis.needs.first
      redirect_to need_path(need)
    else
      redirect_to controller: 'conseiller/diagnoses/steps', action: @diagnosis.step, id: @diagnosis
    end
  end

  private

  def retrieve_diagnosis
    @diagnosis = Diagnosis.find(params.require(:id))
  end

  def diagnosis_params
    params.require(:diagnosis)
      .permit(:solicitation_id, facility_attributes: [ :siret, :insee_code, company_attributes: :name ])
  end
end
