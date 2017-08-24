# frozen_string_literal: true

class DiagnosesController < ApplicationController
  def index
    @diagnoses = UseCases::GetDiagnoses.for_user(current_user)
  end

  def step1; end

  def step2
    @diagnosis = Diagnosis.find params[:id]
    @categories_with_questions = UseCases::GetStep2Data.for_diagnosis @diagnosis
  end

  def step3
    associations = [visit: [facility: [:company]]]
    @diagnosis = Diagnosis.joins(associations)
                          .includes(associations)
                          .find params[:id]
  end

  def step4
    @diagnosis = Diagnosis.find params[:id]
    @diagnosed_needs = DiagnosedNeed.of_diagnosis(@diagnosis)
    associations = [question: [assistances: [assistances_experts: [expert: :institution]]]]
    @diagnosed_needs = @diagnosed_needs.joins(associations).includes(associations)
  end

  def step5
    associations = [visit: [facility: [:company]], diagnosed_needs: [:selected_assistance_experts]]
    @diagnosis = Diagnosis.includes(associations)
                          .find params[:id]
  end

  def notify_experts
    diagnosis = Diagnosis.find params[:id]
    assistances_experts = params[:assistances_experts]
    unless assistances_experts.blank?
      assistance_expert_ids = ExpertMailersService.filter_assistances_experts(assistances_experts)
      UseCases::CreateSelectedAssistancesExperts.perform(diagnosis, assistance_expert_ids)
      # TODO: Use Delayed Jobs to perform email sending ; http://doc.scalingo.com/languages/ruby/delayed-job.html
      ExpertMailersService.send_assistances_email(advisor: current_user, diagnosis: diagnosis,
                                                  assistance_expert_ids: assistance_expert_ids)
    end
    diagnosis.update step: 5
    redirect_to step_5_diagnosis_path(diagnosis)
  end

  def destroy
    diagnosis = Diagnosis.find params[:id]
    diagnosis.destroy
    redirect_to diagnoses_path
  end
end
