class AddArchivedAtToDiagnosis < ActiveRecord::Migration[5.1]
  def up
    add_column :diagnoses, :archived_at, :datetime
    add_index :diagnoses, :archived_at
    execute 'update diagnoses set archived_at = deleted_at'
  end

  def down
    remove_column :diagnoses, :archived_at
  end
end
