module Reminders
  class BaseController < ApplicationController
    before_action :authenticate_admin!

    layout 'side_menu'

    private

    def collection_action_names
      %i[poke last_chance refused]
    end

    def experts_collection_names
      %i[inputs many_pending_needs medium_pending_needs one_pending_need expired_needs outputs]
    end

    # Filtering
    #
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
      @possible_territories_options = Territory.regions.pluck(:name, :id)
      @possible_territories_options.push(
        [ t('helpers.expert.national_perimeter.label'), t('helpers.expert.national_perimeter.value') ]
      )
    end
  end
end
