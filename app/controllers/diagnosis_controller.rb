# frozen_string_literal: true

class DiagnosisController < ApplicationController
  layout 'with_visit_subnavbar'
  
  def new
    @visit = Visit.of_advisor(current_user).includes(:company).find params[:visit_id]
  end

  def create; end

  def show; end

  def index; end

  def question
    @visit = Visit.of_advisor(current_user).includes(:visitee, :facility).find params[:visit_id]
    @question = Question.includes(:assistances, assistances: %i[institution expert]).find params[:id]
  end
end
