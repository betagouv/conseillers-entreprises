# == Schema Information
#
# Table name: additional_subject_questions
#
#  id         :bigint(8)        not null, primary key
#  key        :string
#  position   :integer
#  subject_id :bigint(8)
#
# Indexes
#
#  additional_subject_question_subject_key_index     (subject_id,key) UNIQUE
#  index_additional_subject_questions_on_subject_id  (subject_id)
#
class AdditionalSubjectQuestion < ApplicationRecord
  ## Associations
  #
  belongs_to :subject, inverse_of: :additional_subject_questions
  has_many :institution_filters, dependent: :destroy, inverse_of: :additional_subject_question

  ## Validations
  #
  validates :key, presence: true
  validates :key, uniqueness: { scope: :subject_id }
end
