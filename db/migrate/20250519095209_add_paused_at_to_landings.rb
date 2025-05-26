class AddPausedAtToLandings < ActiveRecord::Migration[7.2]
  def change
    add_column :landings, :paused_at, :datetime
  end
end
