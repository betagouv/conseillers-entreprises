class RemoveRelays < ActiveRecord::Migration[5.2]
  def change
    remove_column :matches, :relay_id
    drop_table :relays
  end
end
