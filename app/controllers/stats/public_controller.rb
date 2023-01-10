module Stats
  class PublicController < BaseController
    before_action :stats_params
    def index
      @stats_params = stats_params
      session[:public_stats_params] = @stats_params
      @main_stat = Stats::Public::ExchangeWithExpertColumnStats.new(@stats_params)
    end

    def solicitations
      render_partial(Stats::Public::All.new(session[:public_stats_params]).solicitations, 'solicitations')
    end

    def solicitations_diagnoses
      render_partial(Stats::Public::All.new(session[:public_stats_params]).solicitations_diagnoses, 'solicitations_diagnoses')
    end

    def exchange_with_expert
      render_partial(Stats::Public::All.new(session[:public_stats_params]).exchange_with_expert, 'exchange_with_expert')
    end

    def needs_done_from_exchange
      render_partial(Stats::Public::All.new(session[:public_stats_params]).needs_done_from_exchange, 'needs_done_from_exchange')
    end

    def taking_care
      render_partial(Stats::Public::All.new(session[:public_stats_params]).taking_care, 'taking_care')
    end

    def themes
      render_partial(Stats::Public::All.new(session[:public_stats_params]).themes, 'themes')
    end

    def companies_by_employees
      render_partial(Stats::Public::All.new(session[:public_stats_params]).companies_by_employees, 'companies_by_employees')
    end

    def companies_by_naf_code
      render_partial(Stats::Public::All.new(session[:public_stats_params]).companies_by_naf_code, 'companies_by_naf_code')
    end

    private

    def render_partial(data, name)
      render partial: 'stats/public/load_stats', locals: { data: data, name: name }
    end
  end
end
