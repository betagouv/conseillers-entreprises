class LandingsController < Landings::BaseController
  before_action :save_form_info

  include IframePrefix

  def home
    @landing = Landing.find_by(slug: 'home')
    @landing_themes = Rails.cache.fetch('landing_themes', expires_in: 3.minutes) do
      @landing.landing_themes.order(:position)
    end
    @landing_emphasis = Landing.emphasis
  end

  def show
    redirect_to landing_theme_path(@landing, @landing_themes.first) unless @landing_themes.many?
  end

  private

  def retrieve_landing
    slug = params[:slug]&.to_sym
    @landing = Rails.cache.fetch("landing-#{slug}", expires_in: 1.minute) do
      Landing.find_by(slug: slug)
    end
    @landing_themes = @landing&.landing_themes&.order(:position)

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
