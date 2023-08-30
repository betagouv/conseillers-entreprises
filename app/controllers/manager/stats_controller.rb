# frozen_string_literal: true

module Manager
  class StatsController < ApplicationController
    include StatsHelper

    def index
      authorize current_user, :index?
      @stats = Stats::Matches::All.new(stats_params)
      managed_antennes = current_user.managed_antennes
      @filters = {
        antennes: Antenne.where(id: [managed_antennes.ids, managed_antennes.map { |a| a.territorial_antennes.map(&:id) }].flatten),
        regions: Territory.where(id: managed_antennes.map(&:regions).flatten).uniq,
        themes: current_user.institution.themes.for_interview.order(:label).uniq,
        subjects: current_user.institution.subjects.for_interview.order(:label).uniq
      }
      @charts_names = [
        :needs_transmitted, :positioning_rate, :taking_care_rate_stats, :done_rate_stats,
        :done_no_help_rate_stats, :done_not_reachable_rate_stats, :not_for_me_rate_stats, :not_positioning_rate
      ]
    end

    def stats_params
      stats_params = stats_filter_params
      stats_params[:start_date] ||= 6.months.ago.beginning_of_month.to_date
      stats_params[:end_date] ||= Date.today
      stats_params[:institution_id] = current_user.institution.id
      stats_params
    end
  end
end
