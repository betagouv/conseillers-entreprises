class Landings::LandingThemesController < Landings::BaseController
  before_action :save_query_params

  def show
    @landing_theme = LandingTheme.find_by(slug: params[:slug])
    # pas de page "theme" pour les landing `single_page`
    redirect_to landing_path(@landing) if (@landing.layout_single_page? && !@landing.iframe)

    @landing_subjects = @landing_theme.landing_subjects.order(:position)
    redirect_to root_path, status: :moved_permanently if @landing_theme.nil?
  end
end
