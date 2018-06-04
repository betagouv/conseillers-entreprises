# frozen_string_literal: true

class DiagnosesController < ApplicationController
  def index
    @diagnoses = UseCases::GetDiagnoses.for_user(current_user)
  end

  def print
    @categories_with_questions = UseCases::GetQuestionsForPdf.perform
    render 'print.pdf'
  end

  def step2
    @diagnosis = fetch_and_check_diagnosis_by_id params[:id]
    @categories_with_questions = UseCases::GetStep2Data.for_diagnosis @diagnosis
  end

  def step3
    @diagnosis = fetch_and_check_diagnosis_by_id params[:id]
  end

  def step4
    @diagnosis = fetch_and_check_diagnosis_by_id params[:id]
    @diagnosed_needs = UseCases::GetDiagnosedNeedsWithFilteredAssistanceExperts.of_diagnosis(@diagnosis)
    @relays_full_names = Relay.of_diagnosis_location(@diagnosis).map(&:user).map(&:full_name)
  end

  def step5
    associations = [visit: [:visitee, facility: [:company]], diagnosed_needs: [:selected_assistance_experts]]
    @diagnosis = Diagnosis.includes(associations).find params[:id]
    check_current_user_access_to(@diagnosis)
  end

  def notify
    diagnosis = fetch_and_check_diagnosis_by_id params[:id]
    experts = params[:selected_assistances_experts]
    if experts.present?
      UseCases::SaveAndNotifyDiagnosis.perform diagnosis, params[:selected_assistances_experts]
      diagnosis.update step: Diagnosis::LAST_STEP
      redirect_to step_5_diagnosis_path(diagnosis), notice: I18n.t('diagnoses.step5.notifications_sent')
    end
  end

  def destroy
    diagnosis = Diagnosis.find params[:id]
    check_current_user_access_to(diagnosis)
    diagnosis.destroy
    redirect_to diagnoses_path
  end

  private

  def fetch_and_check_diagnosis_by_id(diagnosis_id)
    diagnosis = Diagnosis.find diagnosis_id
    check_availability_of_diagnosis(diagnosis)
    check_current_user_access_to(diagnosis)
    diagnosis
  end

  def check_availability_of_diagnosis(diagnosis)
    if diagnosis.step == Diagnosis::LAST_STEP
      not_found
    end
  end
end
