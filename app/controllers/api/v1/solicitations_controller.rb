class Api::V1::SolicitationsController < Api::V1::BaseController

  def create
    result = ApiPde::V1::CreateSolicitation.new(sanitize_params(params), current_institution).call
    if result.success?
      render json: result.solicitation, serializer: serializer, status: 200
    else
      render_error_payload(errors: result.errors, status: :unprocessable_entity)
    end
  end

  private

  def serializer
    Api::V1::SolicitationSerializer
  end
end
