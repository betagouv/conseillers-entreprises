class CreateTerritorialZones < ActiveRecord::Migration[7.2]
  def change
    create_table :territorial_zones do |t|
      t.string :code, null: false
      t.string :zone_type, null: false
      t.string :regions_codes, array: true, default: []
      t.references :zoneable, polymorphic: true, null: false

      t.timestamps
      t.index [:code, :zone_type, :zoneable_type, :zoneable_id], unique: true
    end
  end
end
