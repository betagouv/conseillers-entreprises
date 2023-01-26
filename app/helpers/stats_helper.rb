module StatsHelper
  def stats_filter_params
    params.permit(Stats::BaseStats::FILTER_PARAMS)
  end
end
