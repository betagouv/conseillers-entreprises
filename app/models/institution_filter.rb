# == Schema Information
#
# Table name: institution_filters
#
#  id                             :bigint(8)        not null, primary key
#  filter_value                   :boolean
#  institution_filtrable_type     :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  additional_subject_question_id :bigint(8)
#  institution_filtrable_id       :bigint(8)
#
# Indexes
#
#  index_institution_filters_on_additional_subject_question_id  (additional_subject_question_id)
#  index_institution_filters_on_institution_filtrable           (institution_filtrable_type,institution_filtrable_id)
#  institution_filtrable_additional_subject_question_index      (institution_filtrable_id,institution_filtrable_type,additional_subject_question_id) UNIQUE
#
class InstitutionFilter < ApplicationRecord
  ## Associations
  #
  belongs_to :institution_filtrable, polymorphic: true
  belongs_to :additional_subject_question

  ## Validations
  #
  validates :institution_filtrable_id, uniqueness: { scope: %i[institution_filtrable_type additional_subject_question_id] }

  delegate :key, to: :additional_subject_question

  ## institution_filtrable_type
  # Institution : Lié à une institution il sert à l'inclure ou non en fonction de la réponse
  # Solicitation : Sert pour sauvegarder la réponse à la question additionnelle
  # Need : Sert pour sauvegarder la réponse au niveau du besoin et la comparer à l'institution
end
