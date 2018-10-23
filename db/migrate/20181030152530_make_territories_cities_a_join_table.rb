class MakeTerritoriesCitiesAJoinTable < ActiveRecord::Migration[5.2]
  def change
    rename_table :territory_cities, :communes_territories
  end
end
