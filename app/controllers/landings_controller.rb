class LandingsController < PagesController
  def index
    @landings = Rails.cache.fetch('landings', expires_in: 1.hour) do
      Landing.ordered_for_home.to_a
    end
    @tracking_params = info_params.except(:slug)
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

    @tracking_params = info_params.except(:slug)
    @solicitation = Solicitation.new
    @solicitation.form_info = info_params
  end

  private

  def retrieve_landing
    slug = params[:slug]&.to_sym
    Rails.cache.fetch("landing-#{slug}", expires_in: 1.hour) do
      Landing.find_by(slug: slug)
    end
  end

  def info_params
    params.permit(*Solicitation::FORM_INFO_KEYS)
  end
end
