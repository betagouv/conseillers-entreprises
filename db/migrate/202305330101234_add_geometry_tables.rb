class AddGeometryTables < ActiveRecord::Migration[7.0]
  # This migration exists for consistency in schema.rb.
  # The geo_ tables should be imported manually, see doc/04-Architecture#Cartographie
  def change
    create_table "geo_communes_2022", primary_key: "ogc_fid", id: :serial, force: :cascade do |t|
      t.geometry "wkb_geometry", limit: {:srid=>4326, :type=>"geometry"}
      t.string "code"
      t.string "nom"
      t.string "departement"
      t.string "region"
      t.string "commune"
      t.boolean "plm"
      t.string "epci"
      t.index ["code"], name: "geo_communes_2022_code"
      t.index ["wkb_geometry"], name: "geo_communes_2022_wkb_geometry_geom_idx", using: :gist
    end

    create_table "geo_regions_2022", primary_key: "ogc_fid", id: :serial, force: :cascade do |t|
      t.geometry "wkb_geometry", limit: {:srid=>4326, :type=>"geometry"}
      t.string "code"
      t.string "nom"
      t.index ["code"], name: "geo_regions_2022_code"
      t.index ["wkb_geometry"], name: "geo_regions_2022_wkb_geometry_geom_idx", using: :gist
    end
  end
end
