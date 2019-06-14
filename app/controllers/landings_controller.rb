class LandingsController < ApplicationController
  skip_before_action :authenticate_user!

  layout 'solicitations'

  def index
    @featured_landings = Landing.featured.ordered_for_home
  end

  def show
    @landing = retrieve_landing

    redirect_to root_path if @landing.nil?

    @url_to_root = root_path(index_tracking_params)

    @solicitation = Solicitation.new
    @solicitation.form_info = index_tracking_params
  end

  private

  def retrieve_landing
    slug = safe_params[:slug]&.to_sym
    Landing.find_by(slug: slug)
  end

  def index_tracking_params
    safe_params.slice(*Solicitation::TRACKING_KEYS)
  end

  def safe_params
    params.permit(:slug, *Solicitation::TRACKING_KEYS)
  end
end
