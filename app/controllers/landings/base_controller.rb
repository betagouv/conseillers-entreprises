class Landings::BaseController < PagesController
  include IframePrefix

  before_action :retrieve_landing

  private

  def retrieve_landing
    slug = params[:landing_slug]&.to_sym
    @landing = Rails.cache.fetch("landing-#{slug}", expires_in: 1.minute) do
      Landing.find_by(slug: slug)
    end

    redirect_to root_path, status: :moved_permanently if @landing.nil?
  end
end
