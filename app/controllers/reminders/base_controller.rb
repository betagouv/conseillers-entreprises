module Reminders
  class BaseController < ApplicationController
    before_action :authenticate_admin!

    layout 'side_menu'

    private

    def collection_action_names
      %i[poke last_chance abandon]
    end

    def experts_collection_names
      %i[inputs many_pending_needs medium_pending_needs one_pending_need outputs]
    end

    def collections_counts
      @collections_by_reminders_actions_count = Rails.cache.fetch(['reminders_need', territory_needs]) do
        collection_action_names.index_with { |name| territory_needs.reminders_to(name).size }
      end
      @expert_collections_count = Rails.cache.fetch(['expert_reminders_need', territory_needs, RemindersRegister.current_remainder_category.pluck(:updated_at).max]) do
        experts_collection_names.index_with { |name| territory_experts.send(name).distinct.size }
      end
    end

    # Filtering
    #
    def territory_needs
      @territory_needs ||= Need.apply_filters(reminders_filter_params)
    end

    def territory_experts
      @territory_experts ||= Expert.apply_filters(reminders_filter_params)
    end

    def reminders_filter_params
      session[:reminders_filter_params]&.with_indifferent_access || {}
    end
    helper_method :reminders_filter_params

    def persist_filter_params
      session[:reminders_filter_params] ||= {}
      search_params = params.slice(:by_region, :by_full_name).permit!
      if params[:reset_query].present?
        session[:reminders_filter_params] = {}
      else
        session[:reminders_filter_params] = session[:reminders_filter_params].merge(search_params)
      end
    end

    def setup_territory_filters
      @possible_territories_options = Territory.deployed_regions.pluck(:name, :id)
      @possible_territories_options.push(
        [ t('helpers.expert.national_perimeter.label'), t('helpers.expert.national_perimeter.value') ],
      )
    end
  end
end
