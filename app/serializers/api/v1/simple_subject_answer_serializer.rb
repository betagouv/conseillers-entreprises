class Api::V1::SimpleSubjectAnswerSerializer < ActiveModel::Serializer
  attributes :question_id, :question_label, :answer

  def question_label
    I18n.t(:label, scope: [:activerecord, :attributes, :subject_questions, question.key])
  end

  def question_id
    object.subject_question_id
  end

  def answer
    object.filter_value
  end

  private

  def question
    @question ||= SubjectQuestion.find(question_id)
  end
end
