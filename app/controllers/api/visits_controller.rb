# frozen_string_literal: true

module Api
  class VisitsController < ApplicationController
    def show
      @visit = Visit.find params[:id]
      check_current_user_access_to @visit
    end

    def update
      visit = Visit.find params[:id]
      check_current_user_access_to visit
      UseCases::UpdateVisit.validate_happened_on update_params[:happened_on]
      visit.update update_params
    rescue StandardError => error
      send_error_notifications(error)
      render body: nil, status: :bad_request
    end

    private

    def update_params
      params.require(:visit).permit(%i[happened_on])
    end
  end
end
