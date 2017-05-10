# frozen_string_literal: true

class DiagnosisController < ApplicationController
  def index
    @questions = Question.all.includes(:answers)
  end
end