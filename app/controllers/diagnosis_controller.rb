# frozen_string_literal: true

class DiagnosisController < ApplicationController
  layout 'with_visit_subnavbar'

  def index
    find_visit
  end

  def question
    find_visit
    @question = Question.find(params[:id])
  end

  private

  def find_visit
    @visit = Visit.find params[:visit_id]
  end
end
