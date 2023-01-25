module Stats
  class BaseController < PagesController
    helper_method :permit_params

    private

    def permit_params
      params.permit(Stats::BaseStats::FILTER_PARAMS)
    end

    def stats_params
      permit_params[:start_date] ||= 6.months.ago.beginning_of_month.to_date
      permit_params[:end_date] ||= Date.today
      permit_params
    end
  end
end
