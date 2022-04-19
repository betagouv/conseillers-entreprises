class AddNullConstraintsToMatches < ActiveRecord::Migration[6.1]
  def change
    change_column_null(:matches, :subject_id, false)
    expert = Expert.find(1304)
    change_column_null(:matches, :expert_id, false, expert.id)
  end
end
