class RemoveLastActivityAtToNeed < ActiveRecord::Migration[6.0]
  def change
    remove_column :needs, :last_activity_at, :datetime
  end
end
