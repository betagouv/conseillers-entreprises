class AddArchivedAtToQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :archived_at, :datetime
    add_index :questions, :archived_at
  end
end
