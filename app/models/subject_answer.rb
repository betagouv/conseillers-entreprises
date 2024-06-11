# == Schema Information
#
# Table name: subject_answers
#
#  id                      :bigint(8)        not null, primary key
#  filter_value            :boolean
#  subject_questioned_type :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  subject_question_id     :bigint(8)
#  subject_questioned_id   :bigint(8)
#
# Indexes
#
#  index_institution_filters_on_institution_filtrable       (subject_questioned_type,subject_questioned_id)
#  index_subject_answers_on_subject_question_id             (subject_question_id)
#  institution_filtrable_additional_subject_question_index  (subject_questioned_id,subject_questioned_type,subject_question_id) UNIQUE
#
class SubjectAnswer < ApplicationRecord
  ## subject_questioned_type
  # Solicitation : Sert pour sauvegarder la réponse à la question additionnelle
  # Need : Sert pour sauvegarder la réponse au niveau du besoin et la comparer à l'institution

  ## Associations
  #
  belongs_to :subject_questioned, polymorphic: true
  belongs_to :subject_question
  # belongs_to :grouped_subject_answer

  ## Validations
  #
  validates :subject_questioned_id, uniqueness: { scope: %i[subject_questioned_type subject_question_id] }

  delegate :key, to: :subject_question
end
