class Api::Internal::CommunesController < Api::Internal::BaseController
  def search
    communes = Api::Internal::CommunesSearch.new(params[:q]).call
    render json: communes
  end
end
