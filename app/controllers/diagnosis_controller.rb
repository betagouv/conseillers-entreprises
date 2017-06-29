# frozen_string_literal: true

class DiagnosisController < ApplicationController
  layout 'with_visit_subnavbar'

  def new
    @visit = Visit.of_advisor(current_user).includes(facility: :company).find params[:visit_id]
  end

  def create
    diagnosis = UseCases::CreateDiagnosis.create_with_params create_diagnosis_params
    redirect_to visit_diagnosis_path(visit_id: diagnosis.visit_id, id: diagnosis.id)
  end

  def show
    @visit = Visit.of_advisor(current_user).includes(facility: :company).find params[:visit_id]
    @diagnosis = Diagnosis.of_visit(@visit)
                          .includes(diagnosed_needs: [:question])
                          .find params[:id]
  end

  private

  def create_diagnosis_params
    params.permit([:visit_id, { diagnosed_needs: %i[question_label question_id selected] }])
  end
end
