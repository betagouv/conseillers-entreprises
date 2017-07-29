# frozen_string_literal: true

class DiagnosesController < ApplicationController
  def index
    @diagnoses_count = Diagnosis.of_user(current_user).count
    @diagnoses = Diagnosis.of_user(current_user).reverse_chronological.limited
  end

  def step1; end

  def step2
    @diagnosis = Diagnosis.find params[:id]
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
    associations = [
      :question, question: [
        :assistances, assistances: [
          :assistances_experts, assistances_experts: [:expert, expert: :institution]
        ]
      ]
    ]
    @diagnosed_needs = @diagnosed_needs.joins(associations).includes(associations)
  end

  def notify_experts
    diagnosis = Diagnosis.find params[:id]
    ExpertMailersService.send_assistances_email(
      advisor: current_user,
      diagnosis: diagnosis,
      assistances_experts_hash: params[:assistances_experts]
    )
    redirect_to step_5_diagnosis_path(diagnosis)
  end

  def step5
    @diagnosis = Diagnosis.find params[:id]
  end

  # Former action

  def show
    @visit = Visit.of_advisor(current_user).includes(facility: :company).find params[:visit_id]
    @diagnosis = Diagnosis.of_visit(@visit)
                          .includes(diagnosed_needs: [:question])
                          .find params[:id]
  end
end
