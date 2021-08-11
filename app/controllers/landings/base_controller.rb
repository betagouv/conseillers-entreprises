class Landings::BaseController < PagesController
  include IframePrefix

  before_action :retrieve_landing, except: [:home]

  private

  def retrieve_landing
    slug = params.permit(:landing_slug)[:landing_slug]&.to_sym
    @landing = Rails.cache.fetch("landing-#{slug}", expires_in: 1.minute) do
      Landing.find_by(slug: slug)
    end

    redirect_to root_path, status: :moved_permanently if @landing.nil?
  end

  def save_form_info
    form_info = session[:solicitation_form_info] || {}
    info_params = show_params.slice(*Solicitation::FORM_INFO_KEYS)
    form_info.merge!(info_params)
    session[:solicitation_form_info] = form_info if form_info.present?
  end

  def show_params
    params.permit(:slug, *Solicitation::FORM_INFO_KEYS)
  end
end
