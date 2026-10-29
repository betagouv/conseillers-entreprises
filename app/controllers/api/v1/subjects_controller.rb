class Api::V1::SubjectsController < Api::V1::BaseController
  require_api_key_scope ApiKey::ALL_SUBJECTS

  def index
    subjects = Subject.not_archived.not_excluded_from_qualification.order(:id).includes(:landing_subjects_not_archived).load
    render json: subjects, each_serializer: serializer, meta: { total_results: subjects.size }
  end

  def serializer = Api::V1::SubjectSerializer
end
