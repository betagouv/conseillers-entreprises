class Api::V1::Landings::LandingsController < Api::V1::BaseController
  def index
    landings = current_institution.landings
    render json: landings, each_serializer: Api::V1::LandingSerializer, meta: { total_results: landings.size }
  end

  def show
    landing = Landing.find(params[:id])
    render_serialized_payload {
      API.new(landing, serializer_options).serializable_hash
    }
  end
end
