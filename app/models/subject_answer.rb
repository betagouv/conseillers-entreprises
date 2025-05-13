# == Schema Information
#
# Table name: subject_answers
#
#  id                         :bigint(8)        not null, primary key
#  filter_value               :string
#  subject_questionable_type  :string
#  type                       :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  subject_answer_grouping_id :bigint(8)
#  subject_question_id        :bigint(8)        not null
#  subject_questionable_id    :bigint(8)
#
# Indexes
#
#  index_institution_filters_on_institution_filtrable       (subject_questionable_type,subject_questionable_id)
#  index_subject_answers_on_subject_answer_grouping_id      (subject_answer_grouping_id)
#  index_subject_answers_on_subject_question_id             (subject_question_id)
#  index_subject_answers_on_type                            (type)
#  institution_filtrable_additional_subject_question_index  (subject_questionable_id,subject_questionable_type,subject_question_id) UNIQUE
#
class SubjectAnswer < ApplicationRecord
  ## Associations
  #
  belongs_to :subject_question

  delegate :key, to: :subject_question

  scope :by_subject, -> (subject_id) do
    joins(subject_question: :subject)
      .where(subject_question: { subject_id: subject_id })
  end
end
