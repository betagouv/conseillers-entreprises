module Reminders
  class RemindersController < ApplicationController
    include TerritoryFiltrable

    before_action :authenticate_admin!
    before_action :maybe_review_expert_subjects

    layout 'side_menu'

    private

    def count_needs
      needs = Need.diagnosis_completed
      needs = needs.by_territory(@territory) if @territory.present?
      @count_needs = Rails.cache.fetch(["reminders_need", Need.all, @territory]) do
        {
          reminder_quo_not_taken: needs.diagnosis_completed.reminder_quo_not_taken.size,
          reminder_to_recall: needs.diagnosis_completed.reminder_to_recall.size,
          reminder_institutions: needs.diagnosis_completed.reminder_institutions.size,
          abandoned_without_taking_care: needs.diagnosis_completed.abandoned_without_taking_care.size,
          rejected: needs.diagnosis_completed.rejected.size
        }
      end
    end
  end
end
