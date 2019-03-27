class RenameAssistanceToSkill < ActiveRecord::Migration[5.2]
  def change
    rename_table :assistances, :skills
    rename_column :assistances_experts, :assistance_id, :skill_id
    rename_column :matches, :assistance_title, :skill_title

    rename_table :assistances_experts, :experts_skills
    rename_column :matches, :assistances_experts_id, :experts_skills_id
  end
end
