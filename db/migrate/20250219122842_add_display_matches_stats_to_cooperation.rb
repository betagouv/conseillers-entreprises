class AddDisplayMatchesStatsToCooperation < ActiveRecord::Migration[7.2]
  def change
    add_column :cooperations, :display_matches_stats, :boolean, default: false
  end
end
