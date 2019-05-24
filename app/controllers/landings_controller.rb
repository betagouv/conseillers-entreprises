class LandingsController < ApplicationController
  skip_before_action :authenticate_user!

  layout 'solicitations'

  def index
    @featured_landings = Landing.featured.ordered_for_home
    @stats = stats
  end

  def show
    slug = params[:slug]&.to_sym
    @landing = Landing.find_by(slug: slug)

    redirect_to root_path if @landing.nil?

    @solicitation = Solicitation.new
    @solicitation.form_info = index_tracking_params

    @stats = stats
  end

  private

  def index_tracking_params
    params.permit(Solicitation::TRACKING_KEYS)
  end

  def stats
    stats = Stats::Stats.new
    stats.companies = Stats::CompaniesStats.new(stats)
    stats.needs = Stats::NeedsStats.new(stats)
    stats.experts = Stats::ExpertsStats.new(stats)
    stats
  end
end
