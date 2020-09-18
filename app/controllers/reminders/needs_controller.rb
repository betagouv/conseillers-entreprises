module Reminders
  class NeedsController < ApplicationController
    before_action :authenticate_admin!
    before_action :maybe_review_expert_subjects
    before_action :find_territories

    layout 'side_menu'

    def index
      retrieve_needs :abandoned_quo_not_taken
    end

    def in_progress
      retrieve_needs :reminder_in_progress
      render :index
    end

    def abandoned
      retrieve_needs :abandoned_without_taking_care
      render :index
    end

    private

    def find_territories
      @territories = Territory.regions.order(:name)
      @territory = retrieve_territory
    end

    def retrieve_territory
      safe_params = params.permit(:territory)
      if safe_params[:territory].present?
        Territory.find(safe_params[:territory])
      end
    end

    def retrieve_needs(scope)
      @needs = if @territory.present?
        Need.send(scope).joins(:diagnosis).where(diagnoses: { facility: @territory&.facilities }).page(params[:page])
      else
        Need.send(scope).page(params[:page])
      end
      @status = t("reminders.needs.menu.#{scope}").downcase
    end
  end
end
