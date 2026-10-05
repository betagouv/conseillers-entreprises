class Api::V1::Solicitations::UnqualifiedSerializer < ActiveModel::Serializer
  attributes :id, :subject, :description

  def subject
    object.final_subject_id
  end
end
