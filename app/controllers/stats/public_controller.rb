module Stats
  class PublicController < BaseController
    def index
      @stats = Stats::Public::All.new(stats_params)
    end
  end
end
