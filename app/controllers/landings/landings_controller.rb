class Landings::LandingsController < Landings::BaseController
  before_action :save_query_params

  def home
    @landing = Landing.accueil
    @landing_themes = Rails.cache.fetch('landing_themes', expires_in: 3.minutes) do
      @landing.landing_themes.not_archived.order(:position)
    end
    @landing_emphasis = Landing.emphasis
  end

  def show
    @landing_themes = @landing&.displayable_landing_themes&.not_archived&.order(:position)

    redirect_to_iframe_view if @landing.iframe?
  end

  private

  def redirect_to_iframe_view
    if @landing.subjects_iframe?
      landing_theme = @landing.landing_themes.not_archived.first
      redirect_to({ controller: "landings/landing_themes", action: "show", landing_slug: @landing.slug, slug: landing_theme.slug }.merge(query_params))
    elsif @landing.form_iframe?
      landing_subject = @landing.landing_subjects.not_archived.first
      redirect_to({ controller: "/solicitations", action: "new", landing_slug: @landing.slug, landing_subject_slug: landing_subject.slug }.merge(query_params))
    else
      render :show
    end
  end
end
