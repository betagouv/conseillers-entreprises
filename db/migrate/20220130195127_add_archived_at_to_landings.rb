class AddArchivedAtToLandings < ActiveRecord::Migration[6.1]
  def change
    add_column :landings, :archived_at, :datetime
    add_column :landing_themes, :archived_at, :datetime
    add_column :landing_subjects, :archived_at, :datetime
    add_index :landings, :archived_at
    add_index :landing_themes, :archived_at
    add_index :landing_subjects, :archived_at
  end
end
