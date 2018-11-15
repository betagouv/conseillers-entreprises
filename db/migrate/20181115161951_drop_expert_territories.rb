class DropExpertTerritories < ActiveRecord::Migration[5.2]
  def change
    drop_table :expert_territories
  end
end
