class LandingsController < PagesController
  def index
    @featured_landings = Rails.cache.fetch('featured_landings', expires_in: 1.hour) do
      Landing.featured.ordered_for_home.to_a
    end
    @links_tracking_params = links_tracking_params
  end

  def show
    @landing = retrieve_landing
    if @landing.nil?
      redirect_to root_path
      return
    end

    @landing_topics = Rails.cache.fetch("landing_topics-#{@landing.id}", expires_in: 1.hour) do
      @landing.landing_topics.ordered_for_landing.to_a
    end

    @links_tracking_params = links_tracking_params
    @solicitation = Solicitation.new
    @solicitation.form_info = tracking_params
  end

  private

  def retrieve_landing
    slug = safe_params[:slug]&.to_sym
    Rails.cache.fetch("landing-#{slug}", expires_in: 1.hour) do
      Landing.find_by(slug: slug)
    end
  end

  def tracking_params
    safe_params.slice(*Solicitation::TRACKING_KEYS)
  end

  def links_tracking_params
    tracking_params.except(:slug)
  end

  def safe_params
    params.permit(:slug, *Solicitation::TRACKING_KEYS)
  end
end
