class Api::V1::Landings::LandingsController < Api::V1::BaseController
  def index
    landings = current_institution.landings
    render json: landings, each_serializer: serializer, meta: { total_results: landings.size }
  end

  def show
    landing = Landing.find(params[:id])
    render json: landing, serializer: serializer, meta: { total_themes: landing.landing_themes.size }
  end

  private

  def serializer
    Api::V1::LandingSerializer
  end
end
