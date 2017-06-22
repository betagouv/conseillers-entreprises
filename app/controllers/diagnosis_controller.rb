# frozen_string_literal: true

class DiagnosisController < ApplicationController
  layout 'with_visit_subnavbar'

  def index
    @visit = Visit.of_advisor(current_user).includes(:company).find params[:visit_id]
  end

  def question
    @visit = Visit.of_advisor(current_user).includes(:visitee, :company).find params[:visit_id]
    @question = Question.includes(:assistances, assistances: %i[institution expert]).find params[:id]
  end
end
