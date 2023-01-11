module Stats
  class PublicController < BaseController
    before_action :stats_params
    def index
      @stats_params = stats_params
      session[:public_stats_params] = @stats_params
      @main_stat = Stats::Public::ExchangeWithExpertColumnStats.new(@stats_params)
    end

    def solicitations
      name = 'solicitations'
      data = Rails.cache.fetch(['public-stats', name, session[:public_stats_params]], expires_in: 6.hours) do
        Stats::Public::All.new(session[:public_stats_params]).solicitations
      end
      render_partial(data, name)
    end

    def solicitations_diagnoses
      name = 'solicitations_diagnoses'
      data = Rails.cache.fetch(['public-stats', name, session[:public_stats_params]], expires_in: 6.hours) do
        Stats::Public::All.new(session[:public_stats_params]).solicitations_diagnoses
      end
      render_partial(data, name)
    end

    def exchange_with_expert
      name = 'exchange_with_expert'
      data = Rails.cache.fetch(['public-stats', name, session[:public_stats_params]], expires_in: 6.hours) do
        Stats::Public::All.new(session[:public_stats_params]).exchange_with_expert
      end
      render_partial(data, name)
    end

    def needs_done_from_exchange
      name = 'needs_done_from_exchange'
      data = Rails.cache.fetch(['public-stats', name, session[:public_stats_params]], expires_in: 6.hours) do
        Stats::Public::All.new(session[:public_stats_params]).needs_done_from_exchange
      end
      render_partial(data, name)
    end

    def taking_care
      name = 'taking_care'
      data = Rails.cache.fetch(['public-stats', name, session[:public_stats_params]], expires_in: 6.hours) do
        Stats::Public::All.new(session[:public_stats_params]).taking_care
      end
      render_partial(data, name)
    end

    def themes
      name = 'themes'
      data = Rails.cache.fetch(['public-stats', name, session[:public_stats_params]], expires_in: 6.hours) do
        Stats::Public::All.new(session[:public_stats_params]).themes
      end
      render_partial(data, name)
    end

    def companies_by_employees
      name = 'companies_by_employees'
      data = Rails.cache.fetch(['public-stats', name, session[:public_stats_params]], expires_in: 6.hours) do
        Stats::Public::All.new(session[:public_stats_params]).companies_by_employees
      end
      render_partial(data, name)
    end

    def companies_by_naf_code
      name = 'companies_by_naf_code'
      data = Rails.cache.fetch(['public-stats', name, session[:public_stats_params]], expires_in: 6.hours) do
        Stats::Public::All.new(session[:public_stats_params]).companies_by_naf_code
      end
      render_partial(data, name)
    end

    private

    def render_partial(data, name)
      render partial: 'stats/public/load_stats', locals: { data: data, name: name }
    end
  end
end
