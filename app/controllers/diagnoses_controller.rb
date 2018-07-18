# frozen_string_literal: true

class DiagnosesController < ApplicationController
  def index
    @diagnoses = UseCases::GetDiagnoses.for_user(current_user)
  end

  def show
    diagnosis = Diagnosis.only_active.find(params[:id])
    check_current_user_access_to(diagnosis)
    redirect_to action: "step#{diagnosis.step}", id: diagnosis
  end

  def destroy
    diagnosis = Diagnosis.find params[:id]
    check_current_user_access_to(diagnosis)
    diagnosis.archive!
    redirect_to diagnoses_path
  end

  def step2
    @diagnosis = diagnostic_in_progress(params[:id])
    @categories_with_questions = UseCases::GetStep2Data.for_diagnosis @diagnosis
  end

  def step3
    @diagnosis = diagnostic_in_progress(params[:id])
  end

  def step4
    @diagnosis = diagnostic_in_progress(params[:id])
    @diagnosed_needs = UseCases::GetDiagnosedNeedsWithFilteredAssistanceExperts.of_diagnosis(@diagnosis)
    @relays_full_names = Relay.of_diagnosis_location(@diagnosis).map(&:user).map(&:full_name)
  end

  def notify
    diagnosis = diagnostic_in_progress(params[:id])
    experts = params[:matches]
    if experts.present?
      UseCases::SaveAndNotifyDiagnosis.perform diagnosis, params[:matches]
      diagnosis.update step: Diagnosis::LAST_STEP
      redirect_to step_5_diagnosis_path(diagnosis), notice: I18n.t('diagnoses.step5.notifications_sent')
    end
  end

  def step5
    associations = [visit: [:visitee, facility: [:company]], diagnosed_needs: [:matches]]
    @diagnosis = Diagnosis.includes(associations).find params[:id]
    check_current_user_access_to(@diagnosis)
  end

  private

  def diagnostic_in_progress(diagnosis_id)
    diagnosis = Diagnosis.only_active.find(diagnosis_id)
    check_current_user_access_to(diagnosis)

    if diagnosis.step == Diagnosis::LAST_STEP
      not_found
    end

    diagnosis
  end
end
