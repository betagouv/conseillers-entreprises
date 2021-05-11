module Reminders
  class BaseController < ApplicationController
    include TerritoryFiltrable

    before_action :authenticate_admin!

    layout 'side_menu'

    private

    def collection_names
      %i[poke recall warn archive]
    end

    def collections_counts
      @collections_counts = Rails.cache.fetch(['reminders_need', territory_needs]) do
        collection_names.index_with { |name| territory_needs.reminders_to(name).size }
      end
      @experts_count = Rails.cache.fetch(['expert_reminders_need', territory_needs]) do
        to_remind_experts.size
      end
    end

    def territory_needs
      @territory.present? ? @territory.needs : Need.all
    end

    def to_remind_experts
      experts_pool = @territory&.all_experts || Expert.all
      experts_pool.not_deleted.with_needs_in_inbox.distinct
    end
  end
end
