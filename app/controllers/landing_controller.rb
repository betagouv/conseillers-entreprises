class LandingController < ApplicationController
  skip_before_action :authenticate_user!

  layout 'solicitations'

  def landing
    slug = params[:slug]&.to_sym
    @landing = Landing.find_by(slug: slug)

    redirect_to root_path if @landing.nil?

    @solicitation = Solicitation.new
    @solicitation.form_info = index_tracking_params
  end

  private

  def index_tracking_params
    params.permit(Solicitation::TRACKING_KEYS)
  end
end
