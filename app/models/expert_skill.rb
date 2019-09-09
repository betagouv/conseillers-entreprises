# == Schema Information
#
# Table name: experts_skills
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  expert_id  :bigint(8)        not null
#  skill_id   :bigint(8)        not null
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
  belongs_to :skill, inverse_of: :experts_skills
  belongs_to :expert, inverse_of: :experts_skills

  scope :relevant_for, -> (need) do
    experts_in_commune = need.facility.commune.all_experts

    where(skill: need.subject.skills)
      .where(expert: experts_in_commune)
  end

  scope :support_for, -> (diagnosis) do
    experts_in_commune = diagnosis.facility.commune.all_experts

    support.where(expert: experts_in_commune)
  end

  scope :support, -> { where(skill: Skill.support_skills) }
end
