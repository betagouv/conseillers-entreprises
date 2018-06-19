class RemoveDeletedAtFromDiagnosis < ActiveRecord::Migration[5.1]
  def up
    remove_column :diagnoses, :deleted_at, :datetime
  end

  def down
    add_column :diagnoses, :deleted_at, :datetime
    add_index :diagnoses, :deleted_at
    execute 'update diagnoses set deleted_at = archived_at'
  end
end
