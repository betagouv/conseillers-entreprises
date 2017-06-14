# frozen_string_literal: true

class DiagnosisController < ApplicationController
  def index; end

  def question
    @question = Question.find(params[:id])
  end

  def answer
    @answer = Answer.find(params[:id])
  end
end
