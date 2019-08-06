class RemoveExpertsSkillIdFromMatch < ActiveRecord::Migration[5.2]
  def change
    remove_reference :matches, :experts_skills, foreign_key: true
  end
end
