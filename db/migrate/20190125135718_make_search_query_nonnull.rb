class MakeSearchQueryNonnull < ActiveRecord::Migration[5.2]
  def up
    Search.where(query: nil).delete_all
    change_column_null :searches, :query, false
    add_index :searches, :query
  end

  def down
    change_column_null :searches, :query, true
    remove_index :searches, :query
  end
end
