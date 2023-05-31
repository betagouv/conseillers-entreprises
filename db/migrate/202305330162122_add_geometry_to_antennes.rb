class AddGeometryToAntennes < ActiveRecord::Migration[7.0]
  def change
    add_column :antennes, :wkb_geometry, :geometry, srid: 4326

    add_index :antennes, :wkb_geometry, using: :gist

    up_only do
      # Takes about 50 seconds on a M1 mac
      sql = <<~SQL.squish
        UPDATE
          "antennes"
        SET
          "wkb_geometry" = (
            SELECT
              ST_Union ("geo_communes_2022"."wkb_geometry")
            FROM
              "antennes_communes"
              INNER JOIN "communes" ON "communes"."id" = "antennes_communes"."commune_id"
              INNER JOIN "geo_communes_2022" ON "communes"."insee_code" = "geo_communes_2022"."code"
            WHERE
              "antennes_communes"."antenne_id" = "antennes"."id");
      SQL

      ApplicationRecord.connection.execute(sql)
    end
  end
end
