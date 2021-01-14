class AddCodeRegionToTerritory < ActiveRecord::Migration[6.0]
  def change
    add_column :territories, :code_region, :integer
    add_index :territories, :code_region

    up_only do
      Territory.find(63).update_columns(code_region: 32)
      Territory.find(119).update_columns(code_region: 11)
    end
  end
end
