class LandingsController < ApplicationController
  skip_before_action :authenticate_user!

  layout 'solicitations'

  def index
    @featured_landings = Landing.featured.ordered_for_home
    @stats = stats
  end

  def show
    @landing = retrieve_landing

    redirect_to root_path if @landing.nil?

    @url_to_root = root_path(params.permit(Solicitation::TRACKING_KEYS))

    @solicitation = Solicitation.new
    @solicitation.form_info = index_tracking_params

    @stats = stats
  end

  private

  def retrieve_landing
    slug = params.require(:slug)&.to_sym
    Landing.find_by(slug: slug)
  end

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
