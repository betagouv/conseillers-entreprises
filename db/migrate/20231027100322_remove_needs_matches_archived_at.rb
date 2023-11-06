class RemoveNeedsMatchesArchivedAt < ActiveRecord::Migration[7.0]
  def change
    remove_column :needs, :archived_at, :datetime, precision: nil
    remove_column :diagnoses, :archived_at, :datetime, precision: nil
  end
end
