module Reminders
  class BaseController < ApplicationController
    include TerritoryFiltrable

    before_action :authenticate_admin!
    before_action :maybe_review_expert_subjects

    layout 'side_menu'

    private

    def collection_names
      %i[poke recall warn archive]
    end

    def collections_counts
      needs = @territory.present? ? @territory.needs : Need.all

      @collections_counts = Rails.cache.fetch(['reminders_need', needs]) do
        collection_names.index_with { |name| needs.reminders_to(name).size }
      end
    end
  end
end
