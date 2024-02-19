class Landings::LandingSubjectsController < Landings::BaseController
  before_action :save_query_params

  def index
    @landing_theme = LandingTheme.not_archived.find(params[:id])
    redirect_to root_path and return if @landing_theme.nil?

    @landing_subjects = @landing_theme.landing_subjects.not_archived.order(:position)
  end
end
