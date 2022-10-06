class Api::V1::Landings::LandingThemesController < Api::V1::Landings::BaseController
  before_action :retrieve_landing
  def index
    landing_themes = base_scope

    render json: landing_themes, each_serializer: serializer, meta: { total_results: landing_themes.size }
  end

  def show
    landing_theme = base_scope.find(params[:id])
    render json: landing_theme, serializer: serializer, meta: { total_subjects: landing_theme.landing_subjects.size }
  end

  private

  def serializer
    Api::V1::LandingThemeSerializer
  end

  def base_scope
    @landing.landing_themes.archived(false)
  end
end
