class RemoveSkillTitleToMatches < ActiveRecord::Migration[6.0]
  def change
    remove_column :matches, :skill_title
  end
end
