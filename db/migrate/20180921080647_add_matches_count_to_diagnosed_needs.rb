class AddMatchesCountToDiagnosedNeeds < ActiveRecord::Migration[5.2]
  def up
    add_column :diagnosed_needs, :matches_count, :integer
    DiagnosedNeed.all.pluck(:id).each do |id|
      DiagnosedNeed.reset_counters(id, :matches)
    end
  end

  def down
    remove_column :diagnosed_needs, :matches_count
  end
end
