# frozen_string_literal: true

module Manager
  class StatsController < ApplicationController
    include StatsHelper
    before_action :authorize_index_manager_stats, only: %i[index load_data]
    before_action :set_filters_collections, only: :index
    before_action :set_stats_params, only: :index
    before_action :set_charts_names, only: %i[index load_data]

    def index; end

    def load_data
      name = params.permit(:chart_name)[:chart_name]
      data = Rails.cache.fetch(['manager-stats', name, session[:manager_stats_params]], expires_in: 6.hours) do
        invoke_stats(name, session[:manager_stats_params]) if @charts_names.include?(name)
      end
      render partial: 'stats/load_stats', locals: { data: data, name: name }
    end

    def load_filter_options
      subjects = base_subjects

      response = {
        subjects: subjects.select(:id, :label).uniq
      }

      render json: response.as_json
    end

    private

    def authorize_index_manager_stats
      authorize [:manager, :stats], :index?
    end

    def set_filters_collections
      managed_antennes = current_user.managed_antennes
      @filters = {
        antennes: base_antennes,
        regions: managed_antennes.first.national? ? Territory.regions : Territory.where(id: managed_antennes.map(&:regions).flatten).uniq,
        themes: current_user.institution.themes.for_interview.sort_by(&:label).uniq,
        subjects: base_subjects.uniq
      }
    end

    def set_stats_params
      @stats_params = stats_filter_params
      @stats_params[:start_date] ||= 6.months.ago.beginning_of_month.to_date
      @stats_params[:end_date] ||= Date.today
      # '.to_s' for keep 'plus antennes locales' in params
      @stats_params[:antenne] ||= base_antennes.first[:id].to_s
      @stats_params[:institution_id] = current_user.institution.id
      @stats_params[:colors] = %w[#cacafb #000091]
      session[:manager_stats_params] = @stats_params
    end

    def set_charts_names
      @charts_names = %w[
        needs_transmitted matches_positioning matches_taking_care matches_done
        matches_done_no_help matches_done_not_reachable matches_not_for_me matches_not_positioning
        needs_themes companies_by_employees companies_by_naf_code
      ]
    end

    def base_subjects
      @base_subjects = current_user.institution.subjects.not_archived.for_interview.order(:label)
      @base_subjects = @base_subjects.where(theme_id: params[:theme]) if params[:theme].present?
      @base_subjects
    end

    def base_antennes
      @base_antennes ||= build_manager_antennes_collection(current_user)
      if @base_antennes.empty?
        @base_antennes = [{ name: current_user.managed_antennes.first.name, id: 'no_base_antenne_id' }]
      end
      @base_antennes
    end
  end
end
