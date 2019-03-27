# == Schema Information
#
# Table name: assistances_experts
#
#  id            :bigint(8)        not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assistance_id :bigint(8)
#  expert_id     :bigint(8)
#
# Indexes
#
#  index_assistances_experts_on_assistance_id  (assistance_id)
#  index_assistances_experts_on_expert_id      (expert_id)
#
# Foreign Keys
#
#  fk_rails_...  (assistance_id => assistances.id)
#  fk_rails_...  (expert_id => experts.id)
#

class AssistanceExpert < ApplicationRecord
  belongs_to :assistance
  belongs_to :expert
  has_many :matches, foreign_key: :assistances_experts_id, dependent: :nullify, inverse_of: :assistance_expert

  scope :relevant_for, -> (diagnosed_need) do
    experts_in_commune = diagnosed_need.facility.commune.all_experts
    relevant_assistances = diagnosed_need.question.assistances

    AssistanceExpert
      .where(assistance: relevant_assistances)
      .where(expert: experts_in_commune)
  end
end
