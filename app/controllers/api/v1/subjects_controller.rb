class Api::V1::SubjectsController < Api::V1::BaseController
  def index
    subjects = Subject.not_archived.order(:id).includes(:landing_subjects).load
    render json: subjects, each_serializer: serializer, meta: { total_results: subjects.size }
  end

  def serializer = Api::V1::SubjectSerializer
end
