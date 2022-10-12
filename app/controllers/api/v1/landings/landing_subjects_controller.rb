class Api::V1::Landings::LandingSubjectsController < Api::V1::Landings::BaseController
  before_action :retrieve_landing

  def index
    landing_subjects = base_scope
    render json: landing_subjects, each_serializer: serializer, meta: { total_results: landing_subjects.size }
  end

  def show
    landing_subject = base_scope.find(params[:id])
    render json: landing_subject, serializer: serializer, meta: {}
  end

  def search
    if search_params.empty?
      errors = [{ source: I18n.t('api_pde.query_parameters'), message: I18n.t('api_pde.errors.unrecognized') }]
      render_error_payload(errors: errors, status: 400)
    else
      landing_subject = base_scope.find_by!(slug: search_params[:slug])
      render json: landing_subject, serializer: serializer, meta: {}
    end
  end

  private

  def serializer
    Api::V1::LandingSubjectSerializer
  end

  def base_scope
    @landing.landing_subjects.archived(false)
  end

  def search_params
    params.permit(:slug)
  end
end
