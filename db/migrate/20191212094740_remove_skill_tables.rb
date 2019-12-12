class RemoveSkillTables < ActiveRecord::Migration[6.0]
  def change
    remove_column :matches, :skill_id
    drop_table :experts_skills
    drop_table :skills
  end
end
