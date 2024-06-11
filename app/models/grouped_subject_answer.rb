# == Schema Information
#
# Table name: grouped_subject_answers
#
#  id                      :bigint(8)        not null, primary key
#  seen_at                 :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  company_satisfaction_id :bigint(8)        not null
#  expert_id               :bigint(8)        not null
#  institution_id          :bigint(8)        not null
#
# Indexes
#
#  index_grouped_subject_answers_on_company_satisfaction_id  (company_satisfaction_id)
#  index_grouped_subject_answers_on_expert_id                (expert_id)
#  index_grouped_subject_answers_on_institution_id           (institution_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_satisfaction_id => company_satisfactions.id)
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (institution_id => institutions.id)
#
class GroupedSubjectAnswer < ApplicationRecord
  ## subject_questioned_type
  # Solicitation : Sert pour sauvegarder la réponse à la question additionnelle
  # Need : Sert pour sauvegarder la réponse au niveau du besoin et la comparer à l'institution

  ## Associations
  #
  has_many :subject_answers, dependent: :destroy, inverse_of: :grouped_subject_question
  belongs_to :institution
end
