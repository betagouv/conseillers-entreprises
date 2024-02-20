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
  # 1 Une question additionnelle est liée à un sujet
  # 2 Un InstitutionFilter est lié à une sollicitation avec une valeur filter_value
  # 3 Cet InstitutionFilter est dupliqué et lié à un besoin
  # 4 Il est ensuite comparé à l'InstitutionFilter rattaché à l'institution de l'expert ayant le bon sujet pour créer ou non un matche

  ## Associations
  #
  belongs_to :subject, inverse_of: :additional_subject_questions
  has_many :institution_filters, dependent: :destroy, inverse_of: :additional_subject_question

  ## Validations
  #
  validates :key, presence: true
  validates :key, uniqueness: { scope: :subject_id }
end
