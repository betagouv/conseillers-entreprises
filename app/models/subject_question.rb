# == Schema Information
#
# Table name: subject_questions
#
#  id         :bigint(8)        not null, primary key
#  key        :string
#  position   :integer
#  subject_id :bigint(8)        not null
#
# Indexes
#
#  additional_subject_question_subject_key_index  (subject_id,key) UNIQUE
#  index_subject_questions_on_subject_id          (subject_id)
#
class SubjectQuestion < ApplicationRecord
  ## Associations
  #
  belongs_to :subject, inverse_of: :subject_questions
  has_many :subject_answers, dependent: :destroy, inverse_of: :subject_question
  has_many :subject_answer_filters, class_name: 'SubjectAnswer::Filter', dependent: :destroy, inverse_of: :subject_question

  ## Validations
  #
  validates :key, presence: true
  validates :key, uniqueness: { scope: :subject_id }
end
