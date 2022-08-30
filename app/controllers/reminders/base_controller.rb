module Reminders
  class BaseController < ApplicationController
    include TerritoryFiltrable

    before_action :authenticate_admin!

    layout 'side_menu'

    private

    def collection_names
      %i[poke recall will_be_abandoned archive]
    end

    def experts_collection_names
      %i[critical_rate worrying_rate pending_rate]
    end

    def collections_counts
      @collections_counts = Rails.cache.fetch(['reminders_need', territory_needs]) do
        collection_names.index_with { |name| territory_needs.reminders_to(name).size }
      end
      @expert_collections_count = Rails.cache.fetch(['expert_reminders_need', territory_needs]) do
        experts_collection_names.index_with { |name| PositionningRate::Collection.new(territory_experts).send(name).distinct.size }
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
