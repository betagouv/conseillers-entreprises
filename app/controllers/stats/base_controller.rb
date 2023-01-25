module Stats
  class BaseController < PagesController
    include StatsHelper

    private

    def stats_params
      stats_params = stats_filter_params
      stats_params[:start_date] ||= 6.months.ago.beginning_of_month.to_date
      stats_params[:end_date] ||= Date.today
      stats_params
    end
  end
end
