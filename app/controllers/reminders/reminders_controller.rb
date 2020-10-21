module Reminders
  class RemindersController < ApplicationController
    before_action :authenticate_admin!
    before_action :maybe_review_expert_subjects
    before_action :count_needs

    layout 'side_menu'

    private

    def count_needs
      @count_needs = Rails.cache.fetch(["reminders_need", Need.all]) do
        {
          reminder_quo_not_taken: Need.diagnosis_completed.reminder_quo_not_taken.size.keys.size,
            reminder_in_progress: Need.diagnosis_completed.reminder_in_progress.size,
            abandoned_without_taking_care: Need.diagnosis_completed.abandoned_without_taking_care.size
        }
      end
    end

    def retrieve_territory
      safe_params = params.permit(:territory)
      if safe_params[:territory].present?
        Territory.find(safe_params[:territory])
      end
    end
  end
end
