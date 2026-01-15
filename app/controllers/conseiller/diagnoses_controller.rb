class Conseiller::DiagnosesController < ApplicationController
  before_action :retrieve_diagnosis, only: :show

  def new
    authorize Diagnosis
    @current_solicitation = Solicitation.find_by(id: params[:solicitation])
    @diagnosis = DiagnosisCreation::NewDiagnosis.new(@current_solicitation).call
    if @current_solicitation.present?
      @needs = Need.where(id: Need.diagnosis_completed.for_emails(@current_solicitation.email))
        .or(Need.where(id: Need.diagnosis_completed.for_sirets(@current_solicitation.siret)))
    else
      @needs = []
    end
  end

  def create
    creation_result = DiagnosisCreation::CreateOrUpdateDiagnosis.new(diagnosis_params.merge(advisor: current_user)).call
    @diagnosis = creation_result[:diagnosis]

    if @diagnosis.persisted?
      DiagnosisCreation::Steps.new(@diagnosis).autofill_steps
      redirect_to controller: 'conseiller/diagnoses/steps', action: @diagnosis.step, id: @diagnosis
    else
      @current_solicitation = Solicitation.find_by(id: diagnosis_params[:solicitation_id]) if diagnosis_params[:solicitation_id].present?
      if @current_solicitation.present?
        @needs = Need.where(id: Need.diagnosis_completed.for_emails(@current_solicitation.email))
          .or(Need.where(id: Need.diagnosis_completed.for_sirets(@current_solicitation.siret)))
      else
        @needs = []
      end
      flash.now[:alert] = @diagnosis.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
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
