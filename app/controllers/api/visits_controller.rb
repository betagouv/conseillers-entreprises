# frozen_string_literal: true

module Api
  class VisitsController < ApplicationController

    def update
      visit = Visit.find params[:id]

      validate_happened_at update_params[:happened_at]
      visit.update update_params

    rescue StandardError
      render body: nil, status: :bad_request
    end

    private

    def update_params
      params.require(:visit).permit(%i[happened_at])
    end

    def validate_happened_at happened_at
      DateTime.iso8601(happened_at)
    end
  end
end
