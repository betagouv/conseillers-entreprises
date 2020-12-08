module Reminders
  class BaseController < ApplicationController
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
          reminders_to_poke: needs.diagnosis_completed.reminders_to_poke.size,
          reminders_to_recall: needs.diagnosis_completed.reminders_to_recall.size,
          reminders_to_warn: needs.diagnosis_completed.reminders_to_warn.size,
          abandoned_without_taking_care: needs.diagnosis_completed.abandoned_without_taking_care.size,
          rejected: needs.diagnosis_completed.rejected.size
        }
      end
    end
  end
end
