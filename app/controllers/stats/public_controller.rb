module Stats
  class PublicController < BaseController
    before_action :set_graph_names

    def index
      @stats_params = stats_params
      session[:public_stats_params] = @stats_params
      @main_stat = Stats::Public::ExchangeWithExpertColumnStats.new(@stats_params)
    end

    def load_data
      name = params.permit(:chart_name)[:chart_name]
      data = Rails.cache.fetch(['public-stats', name, session[:public_stats_params]], expires_in: 6.hours) do
        Stats::Public::All.new(session[:public_stats_params]).send(name) if @graph_names.include? name
      end
      render_partial(data, name)
    end

    private

    def render_partial(data, name)
      render partial: 'stats/load_stats', locals: { data: data, name: name }
    end

    def set_graph_names
      @graph_names = %w[solicitations solicitations_diagnoses exchange_with_expert needs_done_from_exchange taking_care themes companies_by_employees companies_by_naf_code]
    end
  end
end
