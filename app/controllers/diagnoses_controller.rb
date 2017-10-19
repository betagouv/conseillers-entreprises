# frozen_string_literal: true

class DiagnosesController < ApplicationController
  def index
    @diagnoses = UseCases::GetDiagnoses.for_user(current_user)
  end

  def print
    @categories_with_questions = UseCases::GetQuestionsForPdf.perform
    render 'print.pdf'
  end

  def step1; end

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
  end

  def step5
    associations = [visit: [:visitee, facility: [:company]], diagnosed_needs: [:selected_assistance_experts]]
    @diagnosis = Diagnosis.includes(associations).find params[:id]
    check_current_user_access_to(@diagnosis)
  end

  def notify_experts
    diagnosis = fetch_and_check_diagnosis_by_id params[:id]
    save_selection_and_notify diagnosis, params[:selected_assistances_experts]
    diagnosis.update step: Diagnosis::LAST_STEP
    redirect_to step_5_diagnosis_path(diagnosis), notice: I18n.t('diagnoses.step5.notifications_sent')
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
    not_found if diagnosis.step == Diagnosis::LAST_STEP
  end

  def save_selection_and_notify(diagnosis, selected_assistances_experts)
    return if selected_assistances_experts.blank?

    assistance_expert_ids = filter_step4_params selected_assistances_experts[:assistances_experts]
    save_assistance_experts_selection_and_notify(diagnosis, assistance_expert_ids)

    territory_user_ids = filter_step4_params selected_assistances_experts[:territory_users]
    save_territory_users_selection_and_notify(diagnosis, territory_user_ids)
  end

  def filter_step4_params(hash)
    hash.select { |_key, value| value == '1' }.keys.map(&:to_i)
  end

  def save_assistance_experts_selection_and_notify(diagnosis, assistance_expert_ids)
    UseCases::CreateSelectedAssistancesExperts.perform(diagnosis, assistance_expert_ids)
    ExpertMailersService.delay.send_assistances_email(advisor: current_user, diagnosis: diagnosis,
                                                      assistance_expert_ids: assistance_expert_ids)
  end

  def save_territory_users_selection_and_notify(diagnosis, territory_user_ids)
    # UseCases::CreateSelectedAssistancesExperts.perform(diagnosis, territory_user_ids)
    # TerritoryUserMailersService.delay.send_assistances_email(advisor: current_user, diagnosis: diagnosis,
    #                                                   territory_user_ids: territory_user_ids)
  end
end
