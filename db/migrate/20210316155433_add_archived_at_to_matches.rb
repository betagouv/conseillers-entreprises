class AddArchivedAtToMatches < ActiveRecord::Migration[6.0]
  def change
    add_column :matches, :archived_at, :datetime
  end
end
