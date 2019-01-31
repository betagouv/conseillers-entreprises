class AddArchivedAtToDiagnosedNeed < ActiveRecord::Migration[5.2]
  def change
    add_column :diagnosed_needs, :archived_at, :datetime
    add_index :diagnosed_needs, :archived_at
  end
end
