class AddRegionsCodesToTerritorialZones < ActiveRecord::Migration[7.2]
  def change
    add_column :territorial_zones, :regions_codes, :string, array: true, default: []
  end
end
