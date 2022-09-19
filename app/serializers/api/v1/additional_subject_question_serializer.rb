class Api::V1::AdditionalSubjectQuestionSerializer < ActiveModel::Serializer
  attributes :id, :key, :position, :subject_id, :question

  def question
    I18n.t(:label, scope: [:activerecord, :attributes, :additional_subject_questions, object.key])
  end
end
