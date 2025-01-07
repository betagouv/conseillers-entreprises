module StatsUtilities
  extend ActiveSupport::Concern

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
    name_splitted = name.split('_')
    category = name_splitted.first.capitalize
    graph = name_splitted[1..].map(&:capitalize).join
    "Stats::#{category}::#{graph}".constantize
  end

  def stats_params
    stats_params = stats_filter_params
    stats_params[:start_date] ||= 6.months.ago.beginning_of_month.to_date
    stats_params[:end_date] ||= Date.today
    stats_params
  end
end
