module Stats
  class BaseController < PagesController
    PERMIT_PARAMS = [:territory, :institution, :antenne, :subject, :integration, :mtm_campaign, :mtm_kwd, :start_date, :end_date, :theme]

    private

    def stats_params
      permit_params = params.permit(PERMIT_PARAMS)
      permit_params[:start_date] ||= 6.months.ago.beginning_of_month.to_date
      permit_params[:end_date] ||= Date.today
      permit_params
    end
  end
end
