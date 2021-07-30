class LandingsController < PagesController
  before_action :save_form_info, only: %i[index show]
  before_action :retrieve_landing, only: %i[show]

  include IframePrefix

  def index
    @landings = Rails.cache.fetch('landings', expires_in: 3.minutes) do
      Landing.ordered_for_home.to_a
    end
    @landing_emphasis = Landing.emphasis
  end

  def home
    @landing = Landing.find_by(slug: 'home')
    @landing_themes = Rails.cache.fetch('landing_themes', expires_in: 3.minutes) do
      @landing.landing_themes.order(:position)
    end
    @landing_emphasis = Landing.emphasis
  end

  def show; end

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
