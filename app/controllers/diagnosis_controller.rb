# frozen_string_literal: true

class DiagnosisController < ApplicationController
  def index; end

  def answer
    @answer = Answer.find(params[:id])
  end
end
