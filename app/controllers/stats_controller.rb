class StatsController < PagesController
  include Pundit
  before_action :set_stats
  before_action :authorize_team, except: [:show]
  def show; end

  def team
    redirect_to action: :quality, params: stats_params
  end

  def quality
    @charts_names = [:needs, :source, :matches, :advisors]
    render :team
  end

  def matches
    @charts_names = []
    render :team
  end

  def deployment
    @charts_names = []
    render :team
  end

  private

  def set_stats
    @stats = Stats::Stats.new(stats_params)
  end

  def authorize_team
    authorize @stats, :team?
  end

  def stats_params
    permit_params = params.permit(:territory, :institution, :start_date, :end_date)
    permit_params[:start_date] ||= 6.months.ago.beginning_of_month.to_date
    permit_params[:end_date] ||= Date.today
    permit_params
  end
end
