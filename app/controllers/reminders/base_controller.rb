module Reminders
  class BaseController < ApplicationController
    include TerritoryFiltrable

    before_action :authenticate_admin!

    layout 'side_menu'

    private

    def collection_action_names
      %i[poke last_chance]
    end

    def collection_status_name
      %i[not_for_me]
    end

    def experts_collection_names
      %i[inputs many_pending_needs medium_pending_needs one_pending_need outputs]
    end

    def collections_counts
      @collections_by_reminders_actions_count = Rails.cache.fetch(['reminders_need', territory_needs]) do
        collection_action_names.index_with { |name| territory_needs.reminders_to(name).size }
      end
      @collections_by_status_counts = Rails.cache.fetch(['reminders_need_by_status', territory_needs]) do
        collection_status_name.index_with { |name| territory_needs.archived(false).where(status: name).size }
      end
      @expert_collections_count = Rails.cache.fetch(['expert_reminders_need', territory_needs]) do
        experts_collection_names.index_with { |name| territory_experts.send(name).distinct.size }
      end
    end

    def territory_needs
      @territory.present? ? @territory.needs : Need.all
    end

    def territory_experts
      @territory.present? ? @territory.all_experts : Expert.all
    end
  end
end
