class Api::V1::SubjectQuestionSerializer < ActiveModel::Serializer
  include NeedsHelper

  attributes :id, :key, :position, :question, :question_type

  def question
    question_label(object.key, :long)
  end

  def question_type
    :boolean
  end
end
