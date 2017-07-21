# frozen_string_literal: true

module Api
  class DiagnosesController < ApplicationController
    def show
      @diagnosis = Diagnosis.find params[:id]
    end

    def create
      render body: nil, status: 201
    end

    def update
      @diagnosis = Diagnosis.find params[:id]
      render status: 500 unless @diagnosis.update(update_params)
    end

    private

    def update_params
      params.require(:diagnosis).permit(:content)
    end
  end
end
