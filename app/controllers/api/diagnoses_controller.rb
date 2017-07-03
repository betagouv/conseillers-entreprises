# frozen_string_literal: true

module Api
  class DiagnosesController < ApiController
    def show
      @diagnosis = Diagnosis.find params[:id]
    end

    def update
      @diagnosis = Diagnosis.find params[:id]
      render status: 500 unless @diagnosis.update(content: update_params[:content])
    end

    private

    def update_params
      params.require(:diagnosis).permit(:content)
    end
  end
end
