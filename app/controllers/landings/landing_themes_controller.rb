class Landings::LandingThemesController < Landings::BaseController
  before_action :save_query_params

  def show
    @landing_theme = LandingTheme.find_by(slug: params[:slug])
    @landing_subjects = @landing_theme.landing_subjects.order(:position)
    redirect_to root_path, status: :moved_permanently if @landing_theme.nil?
  end
end
