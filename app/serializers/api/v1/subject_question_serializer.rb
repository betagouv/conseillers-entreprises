class Api::V1::SubjectQuestionSerializer < ActiveModel::Serializer
  attributes :id, :key, :position, :question, :question_type

  def question
    I18n.t(:label, scope: [:activerecord, :attributes, :subject_questions, object.key])
  end

  def question_type
    :boolean
  end
end
