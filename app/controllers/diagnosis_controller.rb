# frozen_string_literal: true

class DiagnosisController < ApplicationController
  def index
    @questions = Question.without_answer_parent.includes(:answers)
  end

  def answer
    @answer = Answer.find(params[:id])
  end
end
