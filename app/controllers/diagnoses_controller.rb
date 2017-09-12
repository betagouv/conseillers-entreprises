# frozen_string_literal: true

class DiagnosesController < ApplicationController
  def index
    @diagnoses = UseCases::GetDiagnoses.for_user(current_user)
  end

  def step1; end

  def step2
    @diagnosis = Diagnosis.find params[:id]
    check_access_to_diagnosis(@diagnosis)
    @categories_with_questions = UseCases::GetStep2Data.for_diagnosis @diagnosis
  end

  def step3
    associations = [visit: [facility: [:company]]]
    @diagnosis = Diagnosis.joins(associations)
                          .includes(associations)
                          .find params[:id]
    check_access_to_diagnosis(@diagnosis)
  end

  def step4
    @diagnosis = Diagnosis.find params[:id]
    check_access_to_diagnosis(@diagnosis)
    @diagnosed_needs = DiagnosedNeed.of_diagnosis(@diagnosis)
    associations = [question: [assistances: [assistances_experts: [expert: :institution]]]]
    @diagnosed_needs = @diagnosed_needs.joins(associations).includes(associations)
  end

  def step5
    associations = [visit: [facility: [:company]], diagnosed_needs: [:selected_assistance_experts]]
    @diagnosis = Diagnosis.includes(associations).find params[:id]
    check_access_to_diagnosis(@diagnosis)
  end

  def notify_experts
    diagnosis = Diagnosis.find params[:id]
    check_access_to_diagnosis(diagnosis)
    create_selected_ae_and_send_emails(diagnosis, params[:assistances_experts]) if params[:assistances_experts].present?
    diagnosis.update step: 5
    redirect_to step_5_diagnosis_path(diagnosis), notice: I18n.t('diagnoses.step5.notifications_sent')
  end

  def destroy
    diagnosis = Diagnosis.find params[:id]
    check_access_to_diagnosis(diagnosis)
    diagnosis.destroy
    redirect_to diagnoses_path
  end

  private

  def check_access_to_diagnosis(diagnosis)
    not_found unless diagnosis.can_be_viewed_by?(current_user)
  end

  def create_selected_ae_and_send_emails(diagnosis, assistances_experts)
    assistance_expert_ids = ExpertMailersService.filter_assistances_experts(assistances_experts)
    UseCases::CreateSelectedAssistancesExperts.perform(diagnosis, assistance_expert_ids)
    ExpertMailersService.delay.send_assistances_email(advisor: current_user, diagnosis: diagnosis,
                                                      assistance_expert_ids: assistance_expert_ids)
  end
end
