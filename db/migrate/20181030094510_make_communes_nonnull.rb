class MakeCommunesNonnull < ActiveRecord::Migration[5.2]
  def up
    change_column_null :facilities, :commune_id, false
    change_column_null :territory_cities, :commune_id, false
    change_column_null :territory_cities, :territory_id, false
  end

  def down
    change_column_null :territory_cities, :territory_id, true
    change_column_null :territory_cities, :commune_id, true
    change_column_null :facilities, :commune_id, true
  end
end
