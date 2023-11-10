module Stats
  class PublicController < BaseController
    before_action :set_charts_names

    def index
      @stats_params = stats_params
      session[:public_stats_params] = @stats_params
      @main_stat = Stats::Needs::ExchangeWithExpertColumn.new(@stats_params)
    end

    def load_data
      name = params.permit(:chart_name)[:chart_name]
      data = Rails.cache.fetch(['public-stats', name, session[:public_stats_params]], expires_in: 6.hours) do
        invoke_stats(name, session[:public_stats_params]) if @charts_names.include?(name)
      end
      render partial: 'stats/load_stats', locals: { data: data, name: name }
    end

    private

    def set_charts_names
      @charts_names = %w[
        solicitations_completed solicitations_diagnoses needs_quo needs_exchange_with_expert
        needs_done solicitations_taking_care_time needs_themes companies_by_employees companies_by_naf_code
      ]
    end
  end
end
