module Manager
  class StatsController < ApplicationController
    include StatsUtilities
    include SearchFilters

    before_action :authorize_index_manager_stats
    before_action :set_stats_params, only: :index
    before_action :set_charts_names, only: %i[index load_data]

    CHART_NAMES = {
      charts_1: %w[
        needs_transmitted matches_positioning matches_taking_care matches_done
        matches_done_no_help matches_done_not_reachable matches_not_for_me matches_not_positioning
        matches_taken_care_in_three_days matches_taken_care_in_five_days
      ],
      charts_2: %w[
        companies_by_employees companies_by_naf_code
      ],
      themes_1: %w[
        needs_themes_not_from_external_cooperation needs_themes_from_external_cooperation
        needs_subjects_not_from_external_cooperation needs_subjects_from_external_cooperation
      ],
      themes_2: %w[needs_themes_all needs_subjects_all]

    }
    def index
      initialize_filters(all_filter_keys)
      @antenne = Antenne.find(@stats_params[:antenne_id]) if @stats_params[:antenne_id].present?
    end

    def load_data
      name = params.permit(:chart_name)[:chart_name]
      unless CHART_NAMES.values.flatten.include?(name)
        head :not_found and return
      end

      data = Rails.cache.fetch(['manager-stats', name, session[:manager_stats_params]], expires_in: 6.hours) do
        invoke_stats(name, session[:manager_stats_params])
      end
      render partial: 'stats/load_stats', locals: { data: data, name: name }
    end

    private

    def authorize_index_manager_stats
      authorize [:manager, :stats]
    end

    def set_stats_params
      @stats_params = stats_filter_params
      @stats_params[:start_date] ||= 6.months.ago.beginning_of_month.to_date
      @stats_params[:end_date] ||= Date.today
      @stats_params[:antenne_id] ||= default_antenne_id
      @stats_params[:institution_id] = current_user.institution.id
      @stats_params[:colors] = %w[#cacafb #000091]
      session[:manager_stats_params] = @stats_params
    end

    def set_charts_names
      @charts_names = CHART_NAMES[:charts_1] + themes_subjects_charts + CHART_NAMES[:charts_2]
    end

    def themes_subjects_charts
      if base_needs_for_filters.from_external_cooperation.any?
        CHART_NAMES[:themes_1]
      else
        CHART_NAMES[:themes_2]
      end
    end

    # Filtering
    #
    # SearchFilters
    def base_needs_for_filters
      @base_needs_for_filters ||= current_user.supervised_antennes.by_higher_territorial_level.first.perimeter_received_needs.distinct
    end

    def all_filter_keys
      [:antennes, :regions, :themes, :subjects, :cooperations]
    end

    def dynamic_filter_keys
      [:subjects]
    end
  end
end
