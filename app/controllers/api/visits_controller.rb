# frozen_string_literal: true

module Api
  class VisitsController < ApplicationController
    def show
      @visit = Visit.find params[:id]
      check_access_to_visit @visit
    end

    def update
      visit = Visit.find params[:id]
      check_access_to_visit visit
      UseCases::UpdateVisit.validate_happened_at update_params[:happened_at]
      visit.update update_params
    rescue StandardError
      render body: nil, status: :bad_request
    end

    private

    def check_access_to_visit(visit)
      not_found unless visit.can_be_viewed_by?(current_user)
    end

    def update_params
      params.require(:visit).permit(%i[happened_at])
    end
  end
end
