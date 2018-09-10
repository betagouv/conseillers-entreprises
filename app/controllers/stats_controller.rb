# frozen_string_literal: true

class StatsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @users_stats = user_stats
    @activity_stats = activity_stats
  end

  def users
    @stats = user_stats
    render 'stats/stats'
  end

  def activity
    @stats = activity_stats
    render 'stats/stats'
  end

  private

  def user_stats
    stats_in_ranges(history_date_ranges) { |range| users_stats_in(range) }
  end

  def activity_stats
    stats_in_ranges(history_date_ranges) { |range| activity_stats_in(range) }
  end

  def stats_in_ranges(date_ranges)
    date_ranges.each_with_object({}) do |date_range, hash|
      hash[date_range] = yield date_range
    end
  end

  def users_stats_in(date_range)
    users = User.not_admin

    {
      'users.registered': users.where(created_at: date_range).count,
      'users.searchers': users.active_searchers(date_range).count,
      'users.visitors': users.active_diagnosers(date_range, 2).count,
      'users.whose_match_taken_care_of': users.active_answered(date_range, [:taking_care, :done]).count,
      'users.whose_match_done': users.active_answered(date_range, :done).count
    }
  end

  def activity_stats_in(date_range)
    {
      "activity.visits": Diagnosis.joins(:visit).where(visits: { happened_on: date_range }).count,
      "activity.companies_diagnosed": Company.diagnosed_in(date_range).count,
      "activity.diagnosed_needs": DiagnosedNeed.made_in(date_range).count,
      "activity.diagnosed_needs_notified": DiagnosedNeed.where(diagnoses: { step: 5 }).made_in(date_range).count,
      "activity.matches": Match.where(created_at: date_range).count,
      "activity.match_taken_care_of": Match.where(taken_care_of_at: date_range).with_status([:taking_care, :done]).count,
      "activity.match_done": Match.where(taken_care_of_at: date_range).with_status(:done).count,
      "activity.match_not_for_me": Match.where(taken_care_of_at: date_range).with_status(:not_for_me).count,
    }
  end

  def history_date_ranges
    # Make sure min and max are in the same timezone (The one defined for Rails / ActiveSupport in application.rb)
    min_date = User.not_admin.first.created_at.beginning_of_month
    max_date = Time.zone.now.advance(months: 1).beginning_of_month
    ranges = []
    start_date, end_date = min_date, min_date.advance(months: 1)
    while start_date < max_date
      ranges << (start_date..end_date)
      start_date = end_date
      end_date = end_date.advance(months: 1)
    end
    ranges
  end
end
