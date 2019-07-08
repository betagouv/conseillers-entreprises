class AddExpertsAndSkillsToMatches < ActiveRecord::Migration[5.2]
  def change
    add_reference :matches, :expert, foreign_key: true
    add_reference :matches, :skill,  foreign_key: true
  end
end
