# frozen_string_literal: true

module Api
  class DiagnosesController < ApplicationController
    def show
      @diagnosis = Diagnosis.find params[:id]
      check_current_user_access_to(@diagnosis)
    end

    def create
      facility = UseCases::SearchFacility.with_siret_and_save params[:siret]

      if facility
        visit = Visit.create advisor: current_user, facility: facility
      end

      if visit
        @diagnosis = Diagnosis.new visit: visit
      end

      if facility && visit && @diagnosis.save
        render status: :created, location: api_diagnosis_url(@diagnosis)
      else
        render body: nil, status: :bad_request
      end
    end

    def update
      @diagnosis = Diagnosis.find params[:id]
      check_current_user_access_to(@diagnosis)
      @diagnosis.update UseCases::UpdateDiagnosis.clean_update_params update_params, current_step: @diagnosis.step
    rescue StandardError => error
      send_error_notifications(error)
      render body: nil, status: :bad_request
    end

    private

    def update_params
      params.require(:diagnosis).permit(%i[content step])
    end
  end
end
