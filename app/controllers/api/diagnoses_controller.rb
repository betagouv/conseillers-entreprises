# frozen_string_literal: true

module Api
  class DiagnosesController < ApplicationController
    def show
      @diagnosis = Diagnosis.find params[:id]
    end

    def create
      facility = UseCases::SearchFacility.with_siret_and_save params[:siret]
      visit = Visit.create advisor: current_user, facility: facility if facility
      diagnosis = Diagnosis.new visit: visit if visit
      if facility && visit && diagnosis.save
        render json: { id: diagnosis.id }, status: :created, location: api_diagnosis_url(diagnosis)
      else
        render body: nil, status: :bad_request
      end
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
