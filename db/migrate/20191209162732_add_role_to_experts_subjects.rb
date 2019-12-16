class AddRoleToExpertsSubjects < ActiveRecord::Migration[6.0]
  def change
    add_column :experts_subjects, :role, :integer, null: false, default: 0
    add_index :experts_subjects, :role
  end
end
