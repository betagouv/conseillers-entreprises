class Landings::LandingsController < Landings::BaseController
  before_action :save_query_params

  def home
    @landing = Landing.find_by(slug: 'accueil')
    @landing_themes = Rails.cache.fetch('landing_themes', expires_in: 3.minutes) do
      @landing.landing_themes.order(:position)
    end
    @landing_emphasis = Landing.emphasis
  end

  def show
    redirect_to_iframe_view if @landing.iframe?
  end

  private

  def retrieve_landing
    slug = params[:slug]&.to_sym
    @landing = Rails.cache.fetch("landing-#{slug}", expires_in: 1.minute) do
      Landing.find_by(slug: slug)
    end
    @landing_themes = @landing&.landing_themes&.order(:position)
    # Temporary redirections for landings routes
    redirect_to root_path, status: :moved_permanently if @landing.nil?
  end

  def redirect_to_iframe_view
    if @landing.subjects_iframe?
      landing_theme = @landing.landing_themes.first
      redirect_to landing_theme_path(@landing, landing_theme)
    elsif @landing.form_iframe?
      landing_subject = @landing.landing_subjects.first
      redirect_to landing_subject_path(@landing, landing_subject)
    else
      render :show
    end
  end
end
