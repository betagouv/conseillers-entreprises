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
end
