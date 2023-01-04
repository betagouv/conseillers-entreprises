module Stats
  class PublicController < BaseController
    def index
      # @stats = Stats::Public::All.new(stats_params)
      @stats_params = stats_params
      @main_stat = Stats::Public::ExchangeWithExpertColumnStats.new(stats_params)
    end

    def solicitations
      data = Stats::Public::All.new(stats_params).solicitations
      name = 'solicitations'
      render partial: 'stats/public/load_stats', locals: { data: data, name: name }
    end

    def solicitations_diagnoses
      data = Stats::Public::All.new(stats_params).solicitations_diagnoses
      name = 'solicitations_diagnoses'
      render partial: 'stats/public/load_stats', locals: { data: data, name: name }
    end

    def exchange_with_expert
      data = Stats::Public::All.new(stats_params).exchange_with_expert
      name = 'exchange_with_expert'
      render partial: 'stats/public/load_stats', locals: { data: data, name: name }
    end

    def needs_done_from_exchange
      data = Stats::Public::All.new(stats_params).needs_done_from_exchange
      name = 'needs_done_from_exchange'
      render partial: 'stats/public/load_stats', locals: { data: data, name: name }
    end

    def taking_care
      data = Stats::Public::All.new(stats_params).taking_care
      name = 'taking_care'
      render partial: 'stats/public/load_stats', locals: { data: data, name: name }
    end

    def themes
      data = Stats::Public::All.new(stats_params).themes
      name = 'themes'
      render partial: 'stats/public/load_stats', locals: { data: data, name: name }
    end

    def companies_by_employees
      data = Stats::Public::All.new(stats_params).companies_by_employees
      name = 'companies_by_employees'
      render partial: 'stats/public/load_stats', locals: { data: data, name: name }
    end

    def companies_by_naf_code
      data = Stats::Public::All.new(stats_params).companies_by_naf_code
      name = 'companies_by_naf_code'
      render partial: 'stats/public/load_stats', locals: { data: data, name: name }
    end
  end
end
