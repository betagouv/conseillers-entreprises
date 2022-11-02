class Landings::LandingThemesController < Landings::BaseController
  def show
    @landing_theme = LandingTheme.not_archived.find_by(slug: params[:slug])
    redirect_to root_path and return if @landing_theme.nil?
    # pas de page "theme" pour les landing `single_page`
    redirect_to({ controller: "landings/landings", action: "show", landing_slug: @landing.slug }.merge(query_params)) if (@landing.layout_single_page? && !@landing.iframe?)

    @landing_subjects = @landing_theme.landing_subjects.not_archived.order(:position)
  end
end
