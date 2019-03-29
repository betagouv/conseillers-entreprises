class AddArchivedAtToQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :subjects, :archived_at, :datetime
    add_index :subjects, :archived_at
  end
end
