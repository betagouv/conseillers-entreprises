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
    render body: nil
  end

  # Former action

  def show
    @visit = Visit.of_advisor(current_user).includes(facility: :company).find params[:visit_id]
    @diagnosis = Diagnosis.of_visit(@visit)
                          .includes(diagnosed_needs: [:question])
                          .find params[:id]
  end
end
