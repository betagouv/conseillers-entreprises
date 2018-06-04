class RenameTerritoryUsersToRelays < ActiveRecord::Migration[5.1]
  def change
    rename_table :territory_users, :relays
    rename_column :selected_assistances_experts, :territory_user_id, :relay_id

  end
end
