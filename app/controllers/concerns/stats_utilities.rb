module StatsUtilities
  extend ActiveSupport::Concern

  ALLOWED_CHART_NAMES = %w[
    solicitations_completed solicitations_diagnoses needs_positioning needs_done needs_done_no_help
    needs_done_not_reachable needs_not_for_me needs_taking_care needs_taken_care_in_three_days
    needs_taken_care_in_five_days needs_helped_in_five_days needs_themes_all needs_subjects_all
    needs_exchange_with_expert needs_themes_not_from_external_cooperation
    needs_themes_from_external_cooperation needs_subjects_not_from_external_cooperation
    needs_subjects_from_external_cooperation needs_transmitted matches_positioning
    matches_taking_care matches_done matches_done_no_help matches_done_not_reachable
    matches_not_for_me matches_not_positioning matches_taken_care_in_three_days
    matches_taken_care_in_five_days companies_by_employees companies_by_naf_code
  ].freeze

  included do
    helper_method :stats_filter_params
  end

  def invoke_stats(name, params)
    graph = constantize_chart_name(name)
    graph.new(params)
  end

  def stats_filter_params
    params.permit(Stats::BaseStats::FILTER_PARAMS)
  end

  private

  def constantize_chart_name(name)
    raise NameError, 'Invalid chart name' unless ALLOWED_CHART_NAMES.include?(name)

    name_splitted = name.split('_')
    category = name_splitted.first.capitalize
    graph = name_splitted[1..].map(&:capitalize).join
    Stats.const_get(category, false).const_get(graph, false)
  end

  def stats_params
    stats_params = stats_filter_params
    stats_params[:start_date] ||= 6.months.ago.beginning_of_month.to_date
    stats_params[:end_date] ||= Date.today
    stats_params
  end
end
