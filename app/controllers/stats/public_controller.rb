module Stats
  class PublicController < BaseController
    before_action :set_charts_names

    CHART_NAMES = %w[
      solicitations_completed solicitations_diagnoses needs_exchange_with_expert
      needs_done needs_taken_care_in_five_days needs_themes_all companies_by_employees companies_by_naf_code
    ]

    def index
      @stats_params = stats_params
      session[:public_stats_params] = @stats_params
      session[:public_stats_params][:detailed_graphs] = false
      @main_stat = Stats::Needs::DoneWithHelpColumn.new
    end

    def load_data
      name = params.permit(:chart_name)[:chart_name]
      unless CHART_NAMES.include?(name)
        head :not_found and return
      end

      data = Rails.cache.fetch(['public-stats', name, session[:public_stats_params]], expires_in: 6.hours) do
        invoke_stats(name, session[:public_stats_params])
      end
      render partial: 'stats/load_stats', locals: { data: data, name: name }
    end

    private

    def set_charts_names
      @charts_names = CHART_NAMES
    end
  end
end
