# frozen_string_literal: true

module Manager
  class StatsController < ApplicationController
    include StatsHelper
    before_action :authorize_index_manager_stats, only: %i[index load_data]
    before_action :stats_params, only: :index
    before_action :set_filters_collections, only: :index
    before_action :set_charts_names, only: %i[index load_data]

    def index
      @stats = Stats::Manager::All.new(@stats_params)
      session[:manager_stats_params] = @stats_params
    end

    def load_data
      name = params.permit(:chart_name)[:chart_name]
      if @charts_names.include?(name.to_sym)
        data = Rails.cache.fetch(['manager-stats', name, session[:manager_stats_params]], expires_in: 6.hours) do
          Stats::Manager::All.new(session[:manager_stats_params]).send(name)
        end
        render_partial(data, name)
      end
    end

    private

    def authorize_index_manager_stats
      authorize [:manager, :stats], :index?
    end

    def stats_params
      @stats_params = stats_filter_params
      @stats_params[:start_date] ||= 6.months.ago.beginning_of_month.to_date
      @stats_params[:end_date] ||= Date.today
      @stats_params[:antenne] ||= current_user.managed_antennes.first.id
      @stats_params[:institution_id] = current_user.institution.id
      @stats_params[:colors] = %w[#cacafb #000091]
      @stats_params
    end

    def render_partial(data, name)
      render partial: 'stats/load_stats', locals: { data: data, name: name }
    end

    def set_filters_collections
      managed_antennes = current_user.managed_antennes
      @filters = {
        antennes: Antenne.where(id: [managed_antennes.ids, managed_antennes.map { |a| a.territorial_antennes.pluck(:id) }].flatten),
        regions: managed_antennes.first.national? ? Territory.regions : Territory.where(id: managed_antennes.map(&:regions).flatten).uniq,
        themes: current_user.institution.themes.for_interview.order(:label).uniq,
        subjects: current_user.institution.subjects.for_interview.order(:label).uniq
      }
    end

    def set_charts_names
      @charts_names = [
        :needs_transmitted, :positioning_rate, :taking_care_rate_stats, :done_rate_stats,
        :done_no_help_rate_stats, :done_not_reachable_rate_stats, :not_for_me_rate_stats, :not_positioning_rate
      ]
    end
  end
end
