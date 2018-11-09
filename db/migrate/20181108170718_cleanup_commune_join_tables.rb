class CleanupCommuneJoinTables < ActiveRecord::Migration[5.2]
  def change
    # Rename “InterventionZone”: giving it a custom name was pointless, as it doesn’t appear in code, and it prevents us from using the term “intervention zone” elsewhere.
    rename_table :intervention_zones, :antennes_communes

    # The previously named “TerritoryCity” model, which is now just a join table. Remove the old data columns.
    change_table :communes_territories do |t|
      t.remove :created_at, :updated_at, :city_code
    end

    # Remove the now-unused :city_code field from Facility.
    remove_column :facilities, :city_code
  end
end
