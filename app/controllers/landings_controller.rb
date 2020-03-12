class LandingsController < PagesController
  before_action :save_form_info

  def index
    @landings = Rails.cache.fetch('landings', expires_in: 1.hour) do
      Landing.ordered_for_home.to_a
    end
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

    @solicitation = Solicitation.new
  end

  private

  def safe_params
    params.permit(*Solicitation::FORM_INFO_KEYS)
  end

  def retrieve_landing
    slug = safe_params[:slug]&.to_sym
    Rails.cache.fetch("landing-#{slug}", expires_in: 1.hour) do
      Landing.find_by(slug: slug)
    end
  end

  def save_form_info
    form_info = session[:solicitation_form_info] || {}
    form_info.merge!(safe_params)
    session[:solicitation_form_info] = form_info if form_info.present?
  end
end
