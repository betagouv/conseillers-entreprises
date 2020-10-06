class RemoveExpertSubjectRole < ActiveRecord::Migration[6.0]
  def change
    remove_column :experts_subjects, :role, :integer, null: false, default: 0
  end
end
