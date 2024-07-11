# == Schema Information
#
# Table name: subject_answer_groupings
#
#  id             :bigint(8)        not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  institution_id :bigint(8)        not null
#
# Indexes
#
#  index_subject_answer_groupings_on_institution_id  (institution_id)
#
# Foreign Keys
#
#  fk_rails_...  (institution_id => institutions.id)
#
class SubjectAnswerGrouping < ApplicationRecord
  ## Associations
  #
  belongs_to :institution
  has_many :subject_answers, dependent: :destroy, inverse_of: :subject_answer_grouping, class_name: 'SubjectAnswer::Filter'

  scope :by_subject, -> (subject_id) do
    joins(:subject_answers).merge(SubjectAnswer.by_subject(subject_id)).distinct
  end
end
