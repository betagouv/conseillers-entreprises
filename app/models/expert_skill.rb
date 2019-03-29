# == Schema Information
#
# Table name: experts_skills
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  expert_id  :bigint(8)
#  skill_id   :bigint(8)
#
# Indexes
#
#  index_experts_skills_on_expert_id  (expert_id)
#  index_experts_skills_on_skill_id   (skill_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (skill_id => skills.id)
#

class ExpertSkill < ApplicationRecord
  belongs_to :skill
  belongs_to :expert
  has_many :matches, foreign_key: :experts_skills_id, dependent: :nullify, inverse_of: :expert_skill

  scope :relevant_for, -> (diagnosed_need) do
    experts_in_commune = diagnosed_need.facility.commune.all_experts
    relevant_skills = diagnosed_need.question.skills

    ExpertSkill
      .where(skill: relevant_skills)
      .where(expert: experts_in_commune)
  end
end
