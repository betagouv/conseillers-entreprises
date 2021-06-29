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
        to_remind_experts.distinct.size
      end
    end

    def territory_needs
      @territory.present? ? @territory.needs : Need.all
    end

    def to_remind_experts
      experts_pool = @territory&.all_experts || Expert.not_deleted
      experts_pool.with_old_needs_in_inbox
    end
  end
end
