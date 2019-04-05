class AddIsGlobalZoneToExpert < ActiveRecord::Migration[5.2]
  def change
    add_column :experts, :is_global_zone, :boolean, default: false
  end
end
