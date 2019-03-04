class LandingController < ApplicationController
  skip_before_action :authenticate_user!

  layout 'empty'

  def landing
    slug = params[:slug]&.to_sym
    @landing = Landing.find_by(slug: slug)

    redirect_to root_path if @landing.nil?

    @url_to_root = url_to_root(slug)
  end

  private

  def url_to_root(slug)
    tracking_params = { pk_source: 'landing', pk_campaign: 'entreprise', pk_content: slug }
    tracking_params.merge! existing_tracking_params
    root_path(tracking_params)
  end

  def existing_tracking_params
    params.permit(Solicitation::TRACKING_KEYS).to_h.symbolize_keys
  end
end
