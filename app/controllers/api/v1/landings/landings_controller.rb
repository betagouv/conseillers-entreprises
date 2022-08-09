class Api::V1::Landings::LandingsController < Api::V1::BaseController
  def index
    render json: current_institution.landings
  end

  def show
  end
end
