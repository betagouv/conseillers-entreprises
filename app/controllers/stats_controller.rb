class StatsController < PagesController
  include Pundit
  before_action :authorize_team, except: [:show]

  def show
    @stats = Stats::Public::All.new(stats_params)
  end

  def team
    redirect_to action: :quality, params: stats_params
  end

  def quality
    @stats = Stats::Quality::Stats.new(stats_params)
    @charts_names = [:needs_done]
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

  def authorize_team
    authorize Stats::All, :team?
  end

  def stats_params
    permit_params = params.permit(:territory, :institution, :start_date, :end_date)
    permit_params[:start_date] ||= 6.months.ago.beginning_of_month.to_date
    permit_params[:end_date] ||= Date.today
    permit_params
  end
end
