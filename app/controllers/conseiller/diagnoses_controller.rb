class Conseiller::DiagnosesController < ApplicationController
  before_action :retrieve_diagnosis, only: :show

  def new
    authorize Diagnosis
    @current_solicitation = Solicitation.find_by(id: params[:solicitation])
    @diagnosis = DiagnosisCreation::NewDiagnosis.new(@current_solicitation).call
    if @current_solicitation.present?
      @needs = Need.where(id: Need.diagnosis_completed.for_emails(@current_solicitation.email))
        .or(Need.where(id: Need.diagnosis_completed.for_sirets(@current_solicitation.siret)))
      @tab = 'search_manually' if @current_solicitation.siret.nil?
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
      flash[:alert] = @diagnosis.errors.full_messages.to_sentence
      redirect_back_or_to(new_conseiller_diagnosis_path(solicitation: diagnosis_params[:solicitation_id]))
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
