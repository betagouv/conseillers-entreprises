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
          poke: needs.reminders_to(:poke).size,
          recall: needs.reminders_to(:recall).size,
          warn: needs.reminders_to(:warn).size,
          archive: needs.reminders_to(:archive).size,
        }
      end
    end
  end
end
