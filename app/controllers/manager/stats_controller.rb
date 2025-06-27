# frozen_string_literal: true

module Manager
  class StatsController < ApplicationController
    include StatsUtilities
    include ManagerFilters

    before_action :authorize_index_manager_stats, only: %i[index load_data]
    before_action :set_stats_params, only: :index
    before_action :set_charts_names, only: %i[index load_data]

    def index
      initialize_filters(all_filter_keys)
      @antenne = Antenne.find(@stats_params[:antenne_id]) if @stats_params[:antenne_id].present?
    end

    def load_data
      name = params.permit(:chart_name)[:chart_name]
      data = Rails.cache.fetch(['manager-stats', name, session[:manager_stats_params]], expires_in: 6.hours) do
        invoke_stats(name, session[:manager_stats_params]) if @charts_names.include?(name)
      end
      render partial: 'stats/load_stats', locals: { data: data, name: name }
    end

    private

    def authorize_index_manager_stats
      authorize [:manager, :stats], :index?
    end

    def set_stats_params
      @stats_params = stats_filter_params
      @stats_params[:start_date] ||= 6.months.ago.beginning_of_month.to_date
      @stats_params[:end_date] ||= Date.today
      # '.to_s' to keep 'plus antennes locales' in params // base_antennes peut être vide
      @stats_params[:antenne_id] ||= base_antennes&.first&.dig(:id)&.to_s
      @stats_params[:institution_id] = current_user.institution.id
      @stats_params[:colors] = %w[#cacafb #000091]
      session[:manager_stats_params] = @stats_params
    end

    def set_charts_names
      @charts_names = %w[
        needs_transmitted matches_positioning matches_taking_care matches_done
        matches_done_no_help matches_done_not_reachable matches_not_for_me matches_not_positioning
        matches_taken_care_in_three_days matches_taken_care_in_five_days
      ] + themes_subjects_charts +
      %w[
        companies_by_employees companies_by_naf_code
      ]
    end

    def themes_subjects_charts
      if base_needs_for_filters.from_external_cooperation.any?
        %w[needs_themes_not_from_external_cooperation needs_themes_from_external_cooperation needs_subjects_not_from_external_cooperation needs_subjects_from_external_cooperation]
      else
        %w[needs_themes_all needs_subjects_all]
      end
    end

    # Filtering
    #
    # utilisé pour initialisé les filtres ManagerFilters
    def base_needs_for_filters
      @base_needs_for_filters ||= current_user.supervised_antennes.by_higher_territorial_level.first.perimeter_received_needs.distinct
    end

    # Utilisé à l'initialisation de la page
    def all_filter_keys
      [:antennes, :regions, :themes, :subjects, :cooperations]
    end

    # Utilisé lors des chargements dynamiques js des options
    def dynamic_filter_keys
      [:subjects]
    end
  end
end
