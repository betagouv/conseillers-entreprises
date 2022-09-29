class Api::V1::SimpleInstitutionFilterSerializer < ActiveModel::Serializer
  attributes :question_id, :question_label, :answer

  def question_label
    I18n.t(:label, scope: [:activerecord, :attributes, :additional_subject_questions, question.key])
  end

  def question_id
    object.additional_subject_question_id
  end

  def answer
    object.filter_value
  end

  private

  def question
    @question ||= AdditionalSubjectQuestion.find(question_id)
  end
end
