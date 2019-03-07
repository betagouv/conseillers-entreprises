class LandingController < ApplicationController
  skip_before_action :authenticate_user!

  layout 'empty'

  def landing
    slug = params[:slug]&.to_sym
    @landing = Landing.find_by(slug: slug)

    redirect_to root_path if @landing.nil?

    @url_to_root = root_path
  end
end
