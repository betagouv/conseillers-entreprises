class Api::V1::Landings::LandingsController < Api::V1::BaseController
  def index
    landings = base_scope
    render json: landings, each_serializer: serializer, meta: { total_results: landings.size }
  end

  def show
    landing = base_scope.find(params[:id])
    render json: landing, serializer: serializer, meta: { total_themes: landing.landing_themes.size }
  end

  def search
    if search_params.empty?
      errors = [{ source: I18n.t('api_pde.query_parameters'), message: I18n.t('api_pde.errors.unrecognized') }]
      render_error_payload(errors: errors, status: 400)
    else
      cooperation = Cooperation.find_by!(root_url: search_params[:url])
      landings = base_scope.joins(:cooperation).where(cooperation: cooperation)
      render json: landings, each_serializer: serializer, meta: { total_results: landings.size }
    end
  end

  private

  def serializer
    Api::V1::LandingSerializer
  end

  def search_params
    params.permit(:url)
  end

  def base_scope
    current_institution.landings.api.archived(false)
  end
end
