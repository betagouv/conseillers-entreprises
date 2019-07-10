# frozen_string_literal: true

class StatsController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'solicitations'

  def show
    @stats = Stats::Stats.new(stats_params)
  end

  def users
    @stats = users_stats
    render 'stats/stats'
  end

  def activity
    @stats = activity_stats
    render 'stats/stats'
  end

  def cohorts
    @stats = cohorts_stats
    render 'stats/stats'
  end

  def tables
    @users_stats = users_stats
    @activity_stats = activity_stats
    @cohorts_stats = cohorts_stats
  end

  private

  def stats_params
    params.permit(:territory, :institution)
  end

  def users_stats
    stats_in_ranges(history_date_ranges) { |range| users_stats_in(range) }
  end

  def activity_stats
    stats_in_ranges(history_date_ranges) { |range| activity_stats_in(range) }
  end

  def cohorts_stats
    stats_in_ranges(history_date_ranges) { |range| stats_for_cohort_of(range) }
  end

  def stats_in_ranges(date_ranges)
    date_ranges.each_with_object({}) do |date_range, hash|
      objects_in_range = yield date_range
      hash[date_range] = objects_in_range.transform_values(&:count)
    end
  end

  def stats_for_cohort_of(cohort_range)
    cohort = User.not_admin.where(created_at: cohort_range)
    history_date_ranges.each_with_object({}) do |activity_range, hash|
      active = cohort.active_diagnosers(activity_range,2)
      hash[activity_range] = active
    end
  end

  def users_stats_in(date_range)
    users = User.not_admin

    {
      'users.registered': users.where(created_at: date_range),
      'users.searchers': users.active_searchers(date_range),
      'users.matchers': users.active_matchers(date_range),
      'users.whose_match_taken_care_of': users.active_answered(date_range, [:taking_care, :done]),
      'users.whose_match_done': users.active_answered(date_range, :done)
    }
  end

  def activity_stats_in(date_range)
    users = User.not_admin
    visits_in_range = Diagnosis
      .where(happened_on: date_range)
      .where(advisor: users)
    companies_diagnosed_in_range = Company
      .diagnosed_in(date_range)
      .where(diagnoses: { advisor: users })
    needs_in_range = Need
      .made_in(date_range)
      .where(diagnoses: { advisor: users })
    matches_created_in_range = Match
      .where(created_at: date_range)
      .joins(:diagnosis)
      .where(diagnoses: { advisor: users })
    matches_taken_care_in_range = Match
      .where(taken_care_of_at: date_range)
      .joins(:diagnosis)
      .where(diagnoses: { advisor: users })

    {
      "activity.visits": visits_in_range,
      "activity.companies_diagnosed": companies_diagnosed_in_range,
      "activity.needs": needs_in_range,
      "activity.needs_notified": needs_in_range.where(diagnoses: { step: 5 }),
      "activity.matches": matches_created_in_range,
      "activity.match_taken_care_of": matches_taken_care_in_range.where(status: [:taking_care, :done]),
      "activity.match_done": matches_taken_care_in_range.where(status: :done),
      "activity.match_not_for_me": matches_taken_care_in_range.where(status: :not_for_me),
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
