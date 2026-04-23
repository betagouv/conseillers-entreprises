class RemoveIsGlobalZoneToExpert < ActiveRecord::Migration[8.1]
  def change
    remove_column :experts, :is_global_zone, :boolean, default: false, null: false
  end
end
